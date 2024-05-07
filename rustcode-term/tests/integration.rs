#[cfg(feature = "integration")]
mod test {
    mod helpers;

    use rustcode_core::{syntax::AutoPairConfig, Selection};
    use rustcode_term::config::Config;

    use indoc::indoc;

    use self::helpers::*;

    #[tokio::test(flavor = "multi_thread")]
    async fn hello_world() -> anyhow::Result<()> {
        test(("#[\n|]#", "ihello world<esc>", "hello world#[|\n]#")).await?;
        Ok(())
    }

    mod auto_indent;
    mod auto_pairs;
    mod commands;
    mod languages;
    mod movement;
    mod prompt;
    mod splits;
}
