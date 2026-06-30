#!/usr/bin/env bash
# -----------------------------------------------
#  One Piece Terminal Fortune
#  Drop a random One Piece quote every terminal open
# -----------------------------------------------

# --- Quote database ---
# Format: "QUOTE||CHARACTER"
QUOTES=(
  "I've set myself to become the King of the Pirates...and if I die trying...then at least I tried!||Monkey D. Luffy"
  "People's dreams never die!||Marshall D. Teach (Blackbeard)"
  "Power isn't determined by your size, but the size of your heart and dreams!||Marshall D. Teach (Blackbeard)"
  "When do you think people die? When they are shot through the heart by the bullet of a pistol? No. When they are ravaged by an incurable disease? No. When they drink a soup made from a poisonous mushroom? No! It's when they are forgotten!||Dr. Hiluluk"
  "There is someone that I must meet again. And until that day...not even Death itself can take my life away!||Roronoa Zoro"
  "Nothing happened.||Roronoa Zoro"
  "I don't want to conquer anything. I just think the guy with the most freedom in this whole ocean...is the Pirate King!||Monkey D. Luffy"
  "Only those who have suffered long can see the light within the shadows.||Roronoa Zoro"
  "If you hurt somebody or if somebody hurts you, the same red blood will be shed.||Monkey D. Luffy"
  "Inherited will, the destiny of the age, and the dreams of its people. As long as people continue to pursue the meaning of freedom, these things will never cease!||Gol D. Roger"
  "Wealth, fame, power. The man who had acquired everything in this world, the Pirate King, Gold Roger!||Narrator"
  "I can't use a sword that I know nothing about. It would be disrespectful to the sword!||Roronoa Zoro"
  "You want to keep everyone from dying? That's naive. It's war. People die.||Monkey D. Luffy"
  "A real man is someone who forgives another man for his transgressions.||Red-Haired Shanks"
  "Being alone is more painful than getting hurt.||Monkey D. Luffy"
  "I love humans! Ahahaha!||Brook"
  "No matter how hard or impossible it is, never lose sight of your goal.||Monkey D. Luffy"
  "The world isn't perfect. But it's there for us, doing the best it can. That's what makes it so damn beautiful.||Roy Mustang"
  "Courage means being the only one who knows how terrified you are.||Roronoa Zoro"
  "If you want to make your dream come true, you'd better not sleep.||Ace (Portgas D. Ace)"
  "Dying is not repaying a debt! That is not what he saved you for! Only weak men would die after making a woman cry!||Roronoa Zoro"
  "You can't see the whole picture until you look at it from the outside.||Nico Robin"
  "Fools who don't respect the past are doomed to repeat it.||Nico Robin"
  "Loneliness is no longer my concern now. But I do understand loneliness.||Nico Robin"
  "I wanted to live! I wanted to live and I tried my best!||Nami"
  "Even if my soul is in pieces, I'll make it back.||Monkey D. Luffy"
  "If you don't take risks, you can't create a future!||Monkey D. Luffy"
  "There is no 'going back' in life. We can only move forward.||Trafalgar D. Water Law"
  "A lesson with no pain is meaningless. That's because no one can gain without sacrificing something.||Edward Elric"
  "Smiles are always a treasure, even in times of adversity.||Whitebeard (Edward Newgate)"
  "No matter what happens, I'll keep on moving. Until this life runs out of me, I'll keep on walking.||Roronoa Zoro"
  "Compared to the 'righteous' greed of the rulers, the pirates are far more honorable!||Nico Robin"
  "We have to live a life of no regrets.||Portgas D. Ace"
  "Pirates are evil? The Marines are righteous? These are just empty words. Justice will prevail, you say? But of course it will! Whoever wins this war becomes justice!||Donquixote Doflamingo"
  "Stop counting only what you have lost! What is gone, is gone!||Jinbe"
  "The weak don't get to decide anything, not even how they die.||Trafalgar D. Water Law"
  "My wealth and treasures? If you want it, I'll let you have it. Look for it! I left all of it at that place!||Gol D. Roger"
  "I don't care who you are! I will surpass you!||Roronoa Zoro"
  "When you decided to go to sea, it was your own decision. Whatever happens to you on the sea, it depends on what you've got!||Red-Haired Shanks"
  "An enemy attack that sends you flying can crush you flat... but the fact you're still standing proves you survived it.||Brook"
)

# --- Colors ---
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
RESET='\033[0m'

# --- Pick random quote ---
RANDOM_INDEX=$(( RANDOM % ${#QUOTES[@]} ))
ENTRY="${QUOTES[$RANDOM_INDEX]}"

QUOTE="${ENTRY%%||*}"
CHARACTER="${ENTRY##*||}"

# --- Box drawing ---
TERM_WIDTH=60

# Wrap quote text at TERM_WIDTH-4 chars
wrap_text() {
  local text="$1"
  local width=$(( TERM_WIDTH - 4 ))
  local wrapped=""
  local line=""

  for word in $text; do
    if [ $(( ${#line} + ${#word} + 1 )) -le $width ]; then
      [ -n "$line" ] && line="$line $word" || line="$word"
    else
      wrapped="$wrapped\n$line"
      line="$word"
    fi
  done
  [ -n "$line" ] && wrapped="$wrapped\n$line"
  echo -e "${wrapped:2}"  # trim leading \n
}

pad_line() {
  local text="$1"
  local len=${#text}
  local pad=$(( TERM_WIDTH - len - 3 ))
  printf "  %s%${pad}s" "$text" ""
}

# --- Print the box ---
echo ""
echo -e "${RED}${BOLD}  ╔$(printf '═%.0s' $(seq 1 $TERM_WIDTH))╗${RESET}"
echo -e "${RED}${BOLD}  ║$(printf ' %.0s' $(seq 1 $TERM_WIDTH))║${RESET}"

# Print each wrapped line of the quote
while IFS= read -r line; do
  padded=$(pad_line "$line")
  echo -e "${RED}${BOLD}  ║${RESET}${WHITE} $padded${RED}${BOLD}║${RESET}"
done <<< "$(wrap_text "$QUOTE")"

echo -e "${RED}${BOLD}  ║$(printf ' %.0s' $(seq 1 $TERM_WIDTH))║${RESET}"

# Character name line (right aligned)
CHAR_LINE="— $CHARACTER"
CHAR_PAD=$(( TERM_WIDTH - ${#CHAR_LINE} - 1 ))
echo -e "${RED}${BOLD}  ║${RESET}${YELLOW}$(printf ' %.0s' $(seq 1 $CHAR_PAD))$CHAR_LINE ${RED}${BOLD}║${RESET}"

echo -e "${RED}${BOLD}  ║$(printf ' %.0s' $(seq 1 $TERM_WIDTH))║${RESET}"
echo -e "${RED}${BOLD}  ╚$(printf '═%.0s' $(seq 1 $TERM_WIDTH))╝${RESET}"
echo -e "          ${CYAN}${BOLD}~ ONE PIECE ~${RESET}"
echo ""
