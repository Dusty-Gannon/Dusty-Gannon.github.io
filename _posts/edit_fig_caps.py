import re
import sys

def replace_dollar_signs(file_path):
    with open(file_path, 'r') as file:
        content = file.read()

    # Define the regex pattern to find <p class="caption">...</p>
    pattern = r'(<p class="caption">.*?</p>)'
    matches = re.findall(pattern, content, re.DOTALL)

    # Function to replace $$ with \( and \) alternately
    def replace_alternating_dollars(text):
        parts = text.split('$$')
        for i in range(1, len(parts)):
            if i % 2 == 1:
                parts[i] = '\\(' + parts[i]
            else:
                parts[i] = '\\)' + parts[i]
        return ''.join(parts)

    # Replace $$ in each caption
    for match in matches:
        new_caption = replace_alternating_dollars(match)
        content = content.replace(match, new_caption)

    # Write the modified content back to a new file
    new_file_path = file_path.replace('.md', '_modified.md')
    with open(new_file_path, 'w') as file:
        file.write(content)

    print(f"Modified file saved as {new_file_path}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python script.py <file_path>")
        sys.exit(1)
    
    file_path = sys.argv[1]
    replace_dollar_signs(file_path)

