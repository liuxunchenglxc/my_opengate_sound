curl -L -o voices.json https://huggingface.co/rhasspy/piper-voices/resolve/main/voices.json
jq -r 'keys[] | select(test("^(en|ja|zh)")) | [ (split("-")[0] | split("_")[0]), split("-")[0], split("-")[1], split("-")[2] ] | join(" ")' voices.json | while read -r lang locale voice quality; do
    opengate-download-models --short-lang "$lang" --lang "$locale" --name "$voice" --size "$quality"
done