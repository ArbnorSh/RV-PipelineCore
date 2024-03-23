import os
import re
import shutil
import subprocess
import shlex
import logging
import random
import string
from string import Template
import sys
import math

import riscof.utils as utils
import riscof.constants as constants
from riscof.pluginTemplate import pluginTemplate

logger = logging.getLogger()

class rv_core(pluginTemplate):
    __model__ = "rv_core"
    __version__ = "1.0.0"

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

        config = kwargs.get('config')

        # If the config node for this DUT is missing or empty. Raise an error. At minimum we need
        # the paths to the ispec and pspec files
        if config is None:
            print("Please enter input file paths in configuration.")
            raise SystemExit(1)

        # In case of an RTL based DUT, this would be point to the final binary executable of your
        # test-bench produced by a simulator (like verilator, vcs, incisive, etc). In case of an iss or
        # emulator, this variable could point to where the iss binary is located. If 'PATH variable
        # is missing in the config.ini we can hardcode the alternate here.
        self.dut_exe = os.path.join(config['PATH'] if 'PATH' in config else "","rv_core")

        logger.debug('DUT exe: ' + self.dut_exe)

        # Number of parallel jobs that can be spawned off by RISCOF
        # for various actions performed in later functions, specifically to run the tests in
        # parallel on the DUT executable. Can also be used in the build function if required.
        self.num_jobs = str(config['jobs'] if 'jobs' in config else 1)

        # Path to the directory where this python file is located. Collect it from the config.ini
        self.pluginpath=os.path.abspath(config['pluginpath'])

        # Collect the paths to the  riscv-config absed ISA and platform yaml files. One can choose
        # to hardcode these here itself instead of picking it from the config.ini file.
        self.isa_spec = os.path.abspath(config['ispec'])
        self.platform_spec = os.path.abspath(config['pspec'])

        #We capture if the user would like the run the tests on the target or
        #not. If you are interested in just compiling the tests and not running
        #them on the target, then following variable should be set to False
        if 'target_run' in config and config['target_run']=='0':
            self.target_run = False
        else:
            self.target_run = True

    def initialise(self, suite, work_dir, archtest_env):

       # capture the working directory. Any artifacts that the DUT creates should be placed in this
       # directory. Other artifacts from the framework and the Reference plugin will also be placed
       # here itself.
       self.work_dir = work_dir

       # capture the architectural test-suite directory.
       self.suite_dir = suite

       # Note the march is not hardwired here, because it will change for each
       # test. Similarly the output elf name and compile macros will be assigned later in the
       # runTests function
       self.compile_cmd = 'riscv{1}-unknown-elf-gcc -march={0} \
         -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles -g\
         -T '+self.pluginpath+'/env/link.ld\
         -I '+self.pluginpath+'/env/\
         -I '+self.pluginpath+'/../../sw/uart_lib/common/\
         -I ' + archtest_env + ' {2} -o {3} {4}'

       # add more utility snippets here

    def build(self, isa_yaml, platform_yaml):

      # load the isa yaml as a dictionary in python.
      ispec = utils.load_yaml(isa_yaml)['hart0']

      # capture the XLEN value by picking the max value in 'supported_xlen' field of isa yaml. This
      # will be useful in setting integer value in the compiler string (if not already hardcoded);
      self.xlen = ('64' if 64 in ispec['supported_xlen'] else '32')

      # for rv_core start building the '--isa' argument. the self.isa is dutnmae specific and may not be
      # useful for all DUTs
      self.isa = 'rv' + self.xlen
      if "I" in ispec["ISA"]:
          self.isa += 'i'
      if "M" in ispec["ISA"]:
          self.isa += 'i'

      self.compile_cmd = self.compile_cmd+' -mabi='+('lp64 ' if 64 in ispec['supported_xlen'] else 'ilp32 ')

    def runTests(self, testList):

        # we will iterate over each entry in the testList. Each entry node will be referred to by the
        # variable testname.
        for testname in testList:

            logger.debug('Running Test: {0} on DUT'.format(testname))
            # for each testname we get all its fields (as described by the testList format)
            testentry = testList[testname]

            # we capture the path to the assembly file of this test
            test = testentry['test_path']

            # capture the directory where the artifacts of this test will be dumped/created.
            test_dir = testentry['work_dir']

            # name of the elf file after compilation of the test
            elf = 'my.elf'

            # name of the signature file as per requirement of RISCOF. RISCOF expects the signature to
            # be named as DUT-<dut-name>.signature. The below variable creates an absolute path of
            # signature file.
            sig_file = os.path.join(test_dir, self.name[:-1] + ".signature")

            # for each test there are specific compile macros that need to be enabled. The macros in
            # the testList node only contain the macros/values. For the gcc toolchain we need to
            # prefix with "-D". The following does precisely that.
            compile_macros= ' -D' + " -D".join(testentry['macros'])

            # collect the march string required for the compiler
            marchstr = testentry['isa'].lower()

            # substitute all variables in the compile command that we created in the initialize
            # function.
            assembly_files = test + " " + self.pluginpath + "/../../sw/uart_lib/assembly/uart_lib.S"
            cmd = self.compile_cmd.format(marchstr, self.xlen, assembly_files, elf, compile_macros)

            # just a simple logger statement that shows up on the terminal
            logger.debug('Compiling test: ' + test + ', with cmd: ' + cmd)

            # the following command spawns a process to run the compile command. Note here, we are
            # changing the directory for this command to that pointed by test_dir. If you would like
            # the artifacts to be dumped else where change the test_dir variable to the path of your
            # choice.
            utils.shellCommand(cmd).run(cwd=test_dir)

            # Generate bin file from elf
            bin_file = 'my.bin'
            elf_to_bin = 'riscv32-unknown-elf-objcopy -O binary {0} {1}'.format(elf, bin_file)
            utils.shellCommand(elf_to_bin).run(cwd=test_dir)
            
            # Generate hex from bin
            hex_file = 'my.hex'
            bin_to_hex = 'python ../scripts/bin2hex.py {0}/{1} {0}/{2} -w 32'.format(test_dir, bin_file, hex_file)
            utils.shellCommand(bin_to_hex).run()

            # Generate and install vhdl memory
            vhd_mem_file = 'my.vhd'
            hex_to_vhd = 'python ../scripts/hex2vhdmem.py --hex {0}/{1} --vhd {0}/{2}'.format(test_dir, hex_file, vhd_mem_file)
            utils.shellCommand(hex_to_vhd).run()
            copy_vhd = 'cp -f {0}/{1} ../rtl/wishbone_memory/executable_image.vhd'.format(test_dir, vhd_mem_file)
            utils.shellCommand(copy_vhd).run()

            # 2 MB max memory
            max_memory_size = 2 * 1024 * 1024
            hex_stat = os.stat('{0}/{1}'.format(test_dir, hex_file))
            size_in_bytes = hex_stat.st_size
            min_bits_to_represent = 1 if size_in_bytes == 0 else math.ceil(math.log2(size_in_bytes + 1))
            size_power_of_two = 2**min_bits_to_represent
            mem_size = max_memory_size if size_power_of_two > max_memory_size else size_power_of_two
            logger.debug('Memory size for current test: {}'.format(mem_size))
            
            # Verilator
            logger.debug('Compiling verilator executable')
            subprocess.run('make -C ../vidbo clean && make -C ../vidbo -j12 SIZE_MEM={}'.format(mem_size), shell=True)

            if not self.target_run:
                logger.debug('Exiting: Not running the test')
                raise SystemExit
            
            exe_run = self.pluginpath + '/../../vidbo/Vrvsocsim +riscof'

            # Signature file
            signature_file = '{0}/DUT-rv_core.signature'.format(test_dir)
            with open(signature_file, 'w') as file:
                subprocess.Popen(exe_run, shell=True, stdout=file).wait()
            
            logger.debug('DUT executed test')
