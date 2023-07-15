require "./spec_helper"

private def shard_path
  application_path(Shards::SPEC_FILENAME)
end

describe "init" do
  it "creates shard.yml" do
    Dir.cd(application_path) do
      run "shards init"
      File.exists?(application_path(Shards::SPEC_FILENAME)).should be_true
      spec = Shards::Spec.from_file(shard_path)
      spec.name.should eq("integration")
      spec.version.should eq(version "0.1.0")
    end
  end

  it "won't overwrite shard.yml" do
    Dir.cd(application_path) do
      File.write(shard_path, "")
      expect_failure "#{Shards::SPEC_FILENAME} already exists" do
        run "shards init --no-color"
      end
      File.read(shard_path).should be_empty
    end
  end
end
