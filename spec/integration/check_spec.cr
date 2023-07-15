require "./spec_helper"

describe "check" do
  it "succeeds when all dependencies are installed" do
    metadata = {
      dependencies:             {web: "*", orm: "*"},
      development_dependencies: {mock: "*"},
    }
    with_shard(metadata) do
      run "shards install"
      run "shards check"
    end
  end

  it "succeeds when dependencies match loose requirements" do
    with_shard({dependencies: {web: "1.2.0"}}) do
      run "shards install"
    end

    with_shard({dependencies: {web: "~> 1.1"}}) do
      run "shards check"
    end
  end

  it "fails without lockfile" do
    with_shard({dependencies: {web: "*"}}) do
      expect_failure "Missing #{Shards::LOCK_FILENAME}" do
        run "shards check --no-color"
      end
    end
  end

  it "succeeds without dependencies and lockfile" do
    with_shard({name: "no_dependencies"}) do
      run "shards check --no-color"
    end
  end

  it "fails when dependencies are missing" do
    with_shard({dependencies: {web: "*"}}) do
      run "shards install"
    end

    metadata = {
      dependencies:             {web: "*", orm: "*"},
      development_dependencies: {mock: "*"},
    }
    with_shard(metadata) do
      expect_failure "Dependencies aren't satisfied" do
        run "shards check --no-color"
      end
    end
  end

  it "fails when wrong versions are installed" do
    with_shard({dependencies: {web: "1.0.0"}}) do
      run "shards install"
    end

    with_shard({dependencies: {web: "2.0.0"}}) do
      expect_failure "Dependencies aren't satisfied" do
        run "shards check --no-color"
      end
    end
  end

  it "succeeds when shard.yml version doesn't match git tag" do
    metadata = {
      dependencies: {
        version_mismatch: {git: git_url(:version_mismatch), version: "0.2.0"},
      },
    }
    with_shard(metadata) do
      run "shards install"
      run "shards check"
    end
  end

  it "fails when another source was installed" do
    with_shard({dependencies: {awesome: "0.1.0"}}) do
      run "shards install"
    end

    with_shard({dependencies: {awesome: {git: git_url(:forked_awesome)}}}) do
      expect_failure "Dependencies aren't satisfied" do
        run "shards check --no-color"
      end
    end
  end

  it "fails when override changes version to use" do
    metadata = {dependencies: {awesome: "0.1.0"}}

    with_shard(metadata) do
      run "shards install"
    end

    override = {dependencies: {awesome: "0.2.0"}}

    with_shard(metadata, nil, override) do
      expect_failure "Dependencies aren't satisfied" do
        run "shards check --no-color"
      end
    end
  end
end
