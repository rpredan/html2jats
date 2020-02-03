DRAFT ...

1.	When making an XML file, you don’t include file history, which produces error at the PMC style checker. (???)
2.	Figure path: the Indesign exporter puts figures in folder “filename-web-resources\image” and changes all pics to PNG file and I can’t change that. PMC’s rules are either TIFF or EPS figures, which is my standard workflow. So, the question is: How can I indicate the EPS files, since most of the figures are TIFF, so you can rename them in the code properly. You would have to set the figure path to the root of the article. The figures will be properly named as: “zdravvestn-id-lang-number” or “zdravvestn-2810-en-01” and the type will be always PNG which is described before.
3.	Packages: I have the option to package either single articles, issues or volumes in a single package. I think it would be best to package single articles, since it gives us most flexibility. The package (zip) will have the XML, PDF and figures for now.
a.	XML – combined file with “sl” and “en” language or “en” only if the original article is written in English
b.	PDF – I’m not sure about this I will have to package 2 PDFs for bilingual articles … probably
c.	Figures as described in 1.
4.	Corrections: some features aren’t working, or I don’t know how to use.
a.	Dsadsa
5.	You translate html </br> tag into non-recognised <break/> tag in JATS XML which is allowed only in <title>, <td> and <th> tags. In file 2833.html: Line break is in <th> tag but and in child <p> tag …
6.	Bug: Exapmle id: 2855, 3 authors; 2 have two affiliations. First processed normally and the last with: »Error: author name span classes are not "given-name" and "surname": ",". When I delete comma and second affiliation it works properly. Adding comma in front of the reference numbers doesn’t help.
7.	Bug: Corresponden’s email is missing from tag <corresp>. It should be in the <email> tag which is present as <email xlink:type="simple"/>.
8.	XML-all – back matter is the same for both articles … are you suppose to duplicate refs?
9.	<xref ref-type="corresp" rid="en-corr"/> -- tole je problem pri Zvonki -- 3018
