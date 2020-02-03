Carl, 

the jats2idrefs is great and does exactly the job I need it for Thank you very much. 

There are a few corrections and simplifications ... if I might:

1. Simplifications
- The name and the path of the file we will convert is always (or say in most cases): id\id_edifiX_JATSXML.xml (e.g.: 3018\3018_edifiX_JATSXML.xml). Can we simplify that? If I would call just for the folder (e.g. 3018) it will look for the file named "3018_edifiX_JATSXML.xml". If I write a path and different file name, it will try to find that one. 
- can we rename the file form "jats2idrefs" to "jats2txt"? I know it is not accurate, but it is much easier to remember and since I'm the only intended user, it might be ok :-).

2. Corrections
General
You have to finish each reference with a "."

# publication-type="journal"
Looks great.
publication-type="book" (3018)
For reference use 2845_edifiX_JATSXML.xml
OK until "year". 
ref id="b4" should be:
4. Benzian M, Williams D. The Oral Health Atlas. 2nd ed. Geneva: FDI World Dental Federation; 2015. pp. 6-69. (The challenge of oral disease. A call for global action).

# publication-type="book-chapter"
For reference use 2845_edifiX_JATSXML.xml
OK until "date in citation". 
ref id="b41" and "b42" should be:

Never ignore comments. 
Now: 
41. Koprivnikar H. Tobak. Zakotnik J, Tomšič S, Kofol Bric T, Korošec I, Zaletel-Kragelj L, eds. Zdravje in vedenjski slog prebivalcev Slovenije – trendi v raziskavah CINDI 2001–2004–2008. Ljubljana: Inštitut za varovanje zdravja Republike Slovenije; 2012. :71-88. 

It should be:
41. Koprivnikar H. Tobak. In: Zakotnik J, Tomšič S, Kofol Bric T, Korošec I, Zaletel-Kragelj L, eds. Zdravje in vedenjski slog prebivalcev Slovenije – trendi v raziskavah CINDI 2001–2004–2008. Ljubljana: Inštitut za varovanje zdravja Republike Slovenije; 2012. pp. 71-88.

Difference: 
- "In: " (comment tag after chapter-title)
- remove ":" add: "pp. " before page numbers.
-------------- one more: ------------------
For reference use 2845_edifiX_JATSXML.xml
ref id="b54":

Now
54. Amin MB, Edge S, Greene F, Byrd DR, Brookland RK, Washington MK, et al.; eds. AJCC Cancer Staging Manual. 8th ed. Chicago: Springer; 2017.  

Correct:
54. Amin MB, Edge S, Greene F, Byrd DR, Brookland RK, Washington MK, et al., eds. AJCC Cancer Staging Manual. 8th ed. Chicago: Springer; 2017. 

Diff: instead of ";" after et al. put ",".
If "<collab>Happy-collaboration</collab>"" tag after "<etal>et al</etal>., " it would look like:
54. Amin MB, Edge S, Greene F, Byrd DR, Brookland RK, Washington MK, et al., eds; Happy-collaboration. AJCC Cancer Staging Manual. 8th ed. Chicago: Springer; 2017. 


# publication-type="webpage"
For reference use 2845_edifiX_JATSXML.xml
OK until "date in citation". 
ref id="b5" should be:
5. International Agency for Research on Cancer. WHO: International Agency for Research on Cancer. A digital manual for the early diagnosis of oral neoplasia. Squamous cell carcinoma. [cited 2019 Mar 22]. Available from: https://screening.iarc.fr/atlasoral_list.php?cat=B2&amp;lang=1.
-------------- one more: ------------------
For reference use 2845_edifiX_JATSXML.xml
ref id="b56"
If you have punctuation marks like "?" or "!" you skip the "." at the end of <source>. Plus comment and link like before.

Now:\
56. Oral cavity and oropharyngeal cancer. What are oral cavity and oropharyngeal cancers?. 

Correct:
56. Oral cavity and oropharyngeal cancer. What are oral cavity and oropharyngeal cancers? Available from: https://www.cancer.org/content/dam/CRC/PDF/Public/8763.00.pdf.



# publication-type="conference"
look great

# publication-type="thesis"
For reference use 2932_edifiX_JATSXML.xml
ref id="b5" and "b6":

My mistake with at example: square bracket around "Phd Thesis" or "Master's Thesis" should be on the outside of the <thesis> tags:

<ref id="b5">
    <label>5. </label>
    <mixed-citation publication-type="thesis">
        <person-group person-group-type="author">
            <name>
                <surname>Zupanič Pajnič</surname>
                <given-names>I</given-names>
            </name>
        </person-group>. 
        <source>Identifikacija oseb iz starih in slabo ohranjenih bioloških materialov s polimorfizmi mitohondrijske DNA</source>. 
        [<comment>PhD Thesis</comment>].
        <publisher-loc>Ljubljana</publisher-loc>: 
        <publisher-name>I. Zupanič Pajnič</publisher-name>;   
        <year>2007</year>.
    </mixed-citation>
</ref>

Output shoul be:

5. Zupanič Pajnič I. Identifikacija oseb iz starih in slabo ohranjenih bioloških materialov s polimorfizmi mitohondrijske DNA. [PhD Thesis]. Ljubljana: I. Zupanič Pajnič; 2007. 
6. Obal M. Uporaba različnih skeletnih elementov za genetsko identifikacijo žrtev druge svetovne vojne. [Master's Thesis]. Ljubljana: M. Obal; 2018. 