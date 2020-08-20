#


for pad in $(tail +2 list-of-pad.sul | grep -v '^#'); do
  echo pad_url: $pad
  sh framasave.sh $pad
done
