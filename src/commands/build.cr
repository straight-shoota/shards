require "./command"

module Shards
  module Commands
    class Build < Command
      def run(targets, options)
        if spec.targets.empty?
          raise Error.new("Targets not defined in #{SPEC_FILENAME}")
        end

        if targets.empty?
          targets = spec.targets.map(&.name)
        end

        targets.each do |name|
          if target = spec.targets.find { |t| t.name == name }
            Shards.build(target, Shards.bin_path, options)
          else
            raise Error.new("Error target #{name} was not found in #{SPEC_FILENAME}.")
          end
        end
      end
    end
  end

  def self.build(target, bin_path, options = [] of String)
    unless Dir.exists?(bin_path)
      Log.debug { "mkdir #{bin_path}" }
      Dir.mkdir(bin_path)
    end

    Log.info { "Building: #{target.name}" }

    args = [
      "build",
      "-o", File.join(bin_path, target.name),
      target.main,
    ]
    unless Shards.colors?
      args << "--no-color"
    end
    if Shards::Log.level <= ::Log::Severity::Debug
      args << "--verbose"
    end
    options.each { |option| args << option }
    Log.debug { "#{Shards.crystal_bin} #{args.join(' ')}" }

    error = IO::Memory.new
    status = Process.run(Shards.crystal_bin, args: args, output: Process::Redirect::Inherit, error: error)
    if status.success?
      STDERR.puts error unless error.empty?
    else
      raise Error.new("Error target #{target.name} failed to compile:\n#{error}")
    end
  end
end
