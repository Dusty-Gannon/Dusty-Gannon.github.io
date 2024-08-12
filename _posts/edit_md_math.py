import argparse
import re

def replace_dollar_signs_in_caption(caption_text):
    # Replace $$ alternately with \( and \) in captions
    def replacer(match):
        replacer.counter += 1
        return '\\(' if replacer.counter % 2 == 0 else '\\)'
    replacer.counter = -1

    return re.sub(r'\$\$', replacer, caption_text)

def replace_dollar_signs_outside_captions(text):
    # Replace $$ with $ unless preceded or followed by two newlines
    pattern = re.compile(r'(?<!\n\n)\$\$(?!\n\n)', re.DOTALL)
    return pattern.sub('$', text)

def process_file(input_path, output_path, single_dollar=False):
    with open(input_path, 'r') as file:
        content = file.read()

    # Regular expression to find captions
    pattern = re.compile(r'(<p class="caption">.*?</p>)', re.DOTALL)
    def replace_caption(match):
        caption = match.group(1)
        updated_caption = replace_dollar_signs_in_caption(caption)
        return updated_caption

    # Replace content within <p class="caption">...</p>
    content_with_updated_captions = pattern.sub(replace_caption, content)

    if single_dollar:
        # Replace $$ with $ outside captions
        content_with_updated_captions = replace_dollar_signs_outside_captions(content_with_updated_captions)

    with open(output_path, 'w') as file:
        file.write(content_with_updated_captions)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Process markdown file for dollar sign replacements in figure captions.')
    parser.add_argument('input_path', type=str, help='Path to the input markdown file')
    parser.add_argument('output_path', type=str, help='Path to the output markdown file')
    parser.add_argument('--single_dollar', action='store_true', help='Replace $$ with $ outside of captions')

    args = parser.parse_args()

    process_file(args.input_path, args.output_path, single_dollar=args.single_dollar)



