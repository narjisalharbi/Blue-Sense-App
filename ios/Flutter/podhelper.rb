def install_all_flutter_pods(flutter_application_path)
    engine_dir = File.expand_path('engine', flutter_application_path)
    framework_dir = File.expand_path('Flutter', flutter_application_path)
  
    pod 'Flutter', :path => framework_dir
  
    # Flutter plugins
    symlinks_dir = File.expand_path('.symlinks', flutter_application_path)
    Dir.foreach(symlinks_dir) do |plugin|
      next if plugin == '.' || plugin == '..'
      plugin_path = File.join(symlinks_dir, plugin, 'ios')
      if File.exist?(plugin_path)
        pod plugin, :path => plugin_path
      end
    end
  end
  