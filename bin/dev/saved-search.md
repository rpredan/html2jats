# Search XML

shranjena iskanja za reference XML edit

1. Label: zamenjaj več presledkov za labelo z enim
search: (?<=(\.))\s{2,}(?=</label>)
replace: " "

2. et al. piko ven iz taga -- popravi za edifixom

search: 
et al.</etal>
(\s+)</person-group>

replace:
et al</etal>
$1</person-group>.

3. ukini trailing spaces (več kot dva) in nadomesti z enim
find: \s{2,}+$
replace: " "

