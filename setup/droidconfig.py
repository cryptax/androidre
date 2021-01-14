import os
import configparser

# ------------------------- DroidLysis Configuration file -----------------

APKTOOL_JAR = os.path.join( os.path.expanduser("/opt/apktool/"), "apktool.jar")
BAKSMALI_JAR = os.path.join(os.path.expanduser("/opt"), "baksmali.jar")
DEX2JAR_CMD = os.path.join(os.path.expanduser("/opt/dex-tools-2.1-SNAPSHOT"), "d2j-dex2jar.sh")
PROCYON_JAR = os.path.join( os.path.expanduser("/opt"), "procyon-decompiler.jar")
INSTALL_DIR = os.path.dirname(__file__)
SQLALCHEMY = 'sqlite:///droidlysis.db' # https://docs.sqlalchemy.org/en/latest/core/engines.html#database-urls
KEYTOOL = os.path.join( "/usr/bin/keytool" )

# ------------------------- Property configuration files -------------------
SMALI_CONFIGFILE = os.path.join(os.path.join(INSTALL_DIR, './conf/smali.conf'))
WIDE_CONFIGFILE= os.path.join(os.path.join(INSTALL_DIR, './conf/wide.conf'))
ARM_CONFIGFILE =  os.path.join(os.path.join(INSTALL_DIR, './conf/arm.conf'))
KIT_CONFIGFILE =  os.path.join(os.path.join(INSTALL_DIR, './conf/kit.conf'))

# ------------------------- Reading *.conf configuration files -----------

class droidconfig:
    def __init__(self, filename, verbose=False):
        assert filename != None, "Filename is invalid"
        assert os.access(filename, os.R_OK) != False, "File {0} is not readable".format(filename)

        self.filename = filename
        self.verbose = verbose
        self.configparser = configparser.RawConfigParser()

        if self.verbose:
            print( "Reading configuration file: '%s'" % (filename))
        self.configparser.read(filename)

    def get_sections(self):
        return self.configparser.sections()

    def get_pattern(self, section):
        return self.configparser.get(section, 'pattern')

    def get_description(self, section):
        try:
            return self.configparser.get(section, 'description')
        except (configparser.NoSectionError, configparser.NoOptionError):
            pass
        return None

    def get_all_regexp(self):
        # reads the config file and returns a list of all patterns for all sections
        # the patterns are concatenated with a |
        # throws NoSectionError, NoOptionError
        allpatterns=''
        for section in self.configparser.sections():
            if allpatterns == '':
                allpatterns = self.configparser.get(section, 'pattern')
            else:
                allpatterns= self.configparser.get(section, 'pattern') + '|' + allpatterns
        return bytes(allpatterns, 'utf-8')

    def match_properties(self, match, properties):
        '''
        Call this when the recursive search has been done to analyze the results
        and understand which properties have been spotted.

        match: returned by droidutil.recursive_search. This is a dictionary
        of matching lines ordered by matching keyword (pattern)

        properties: dictionary of properties where the key is the property name
        and the value will be False/True if set or not
        
        throws NoSessionError, NoOptionError
        '''
        for section in self.configparser.sections():
            pattern_list = self.configparser.get(section, 'pattern').split('|')
            properties[section] = False
            for pattern in pattern_list:
                if match[pattern]:
                    if self.verbose:
                        print( "Setting properties[%s] = True (matches %s)" % (section, pattern))
                    properties[section] = True
                    break


