/**
 * Copyright (c) 2014 by Software Engineering Lab. of Sungkyunkwan University. All Rights Reserved.
 * 
 * Permission to use, copy, modify, and distribute this software and its documentation for
 * educational, research, and not-for-profit purposes, without fee and without a signed licensing agreement,
 * is hereby granted, provided that the above copyright notice appears in all copies, modifications, and distributions.
 */
package edu.skku.selab.blp.blia.indexer;

import java.io.FileInputStream;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.TreeSet;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import edu.skku.selab.blp.Property;
import edu.skku.selab.blp.common.Bug;
import edu.skku.selab.blp.db.dao.BugDAO;
import edu.skku.selab.blp.db.dao.SourceFileDAO;
import edu.skku.selab.blp.indexer.ICorpusCreator;
import edu.skku.selab.blp.utils.Splitter;
import edu.skku.selab.blp.utils.Stem;
import edu.skku.selab.blp.utils.Stopword;

/**
 * Create each bug corpus from each bug report.  
 * 
 * @author Klaus Changsun Youm(klausyoum@skku.edu)
 *
 */
public class BugCorpusCreator implements ICorpusCreator {
	
	/* (non-Javadoc)
	 * @see edu.skku.selab.blia.indexer.ICorpus#create()
	 */
	@Override
	public void create() throws Exception {
		Property property = Property.getInstance();
		String productName = property.getProductName();
		ArrayList<Bug> list = parseXML();
		property.setBugReportCount(list.size());

		BugDAO bugDAO = new BugDAO();
		Bug bug;
		Iterator<Bug> bugIter = list.iterator();
		
		while (bugIter.hasNext()) {
			bug = (Bug) bugIter.next();
			bug.setProductName(productName);

			String content = (new StringBuilder(String.valueOf(bug.getSummary())))
					.append(" ").append(bug.getDescription()).toString();
			String splitWords[] = Splitter.splitNatureLanguage(content);
			StringBuffer corpuses = new StringBuffer();
			String as[];
			int j = (as = splitWords).length;
			for (int i = 0; i < j; i++) {
				String word = as[i];
				word = Stem.stem(word.toLowerCase());
				if (!Stopword.isEnglishStopword(word)) {
					corpuses.append((new StringBuilder(String.valueOf(word))).append(" ").toString());
				}
			}
			bug.setCorpuses(corpuses.toString());

			// DO NOT insert corpus here~!
			// Creating BugCorpus willl be done at BugVectorCreator
//			String[] corpusArray = corpuses.toString().split(" ");
//			for (int i = 0; i < corpusArray.length; i++) {
//				bugDAO.insertCorpus(corpusArray[i], productName);
//			}
			
			bugDAO.insertBug(bug);
			
			TreeSet<String> fixedFiles = bug.getFixedFiles();
			Iterator<String> fixedFilesIter = fixedFiles.iterator();
			while (fixedFilesIter.hasNext()) {
				String fixedFileName = (String) fixedFilesIter.next();
				bugDAO.insertBugFixedFileInfo(bug.getID(), fixedFileName, SourceFileDAO.DEFAULT_VERSION_STRING, productName);
			}
		}
	}

	private ArrayList<Bug> parseXML() {
		ArrayList<Bug> list = new ArrayList<Bug>();
		DocumentBuilderFactory domFactory = DocumentBuilderFactory.newInstance();
		Property property = Property.getInstance();
		
		try {
			DocumentBuilder domBuilder = domFactory.newDocumentBuilder();
			InputStream is = new FileInputStream(property.getBugFilePath());
			Document doc = domBuilder.parse(is);
			Element root = doc.getDocumentElement();
			NodeList bugRepository = root.getChildNodes();
			if (null != bugRepository) {
				for (int i = 0; i < bugRepository.getLength(); i++) {
					Node bugNode = bugRepository.item(i);
					if (bugNode.getNodeType() == 1) {
						String bugId = bugNode.getAttributes().getNamedItem("id").getNodeValue();
						String openDateString = bugNode.getAttributes().getNamedItem("opendate").getNodeValue();
						String fixDateString = bugNode.getAttributes().getNamedItem("fixdate").getNodeValue();
						Bug bug = new Bug();
						bug.setID(bugId);
						bug.setOpenDateString(openDateString);
						bug.setFixedDateString(fixDateString);
						for (Node node = bugNode.getFirstChild(); node != null; node = node.getNextSibling()) {
							if (node.getNodeType() == 1) {
								if (node.getNodeName().equals("buginformation")) {
									NodeList _l = node.getChildNodes();
									for (int j = 0; j < _l.getLength(); j++) {
										Node _n = _l.item(j);
										if (_n.getNodeName().equals("summary")) {
											String summary = _n.getTextContent();
											bug.setSummary(summary);
										}
										if (_n.getNodeName().equals("description")) {
											String description = _n.getTextContent();
											bug.setDescription(description);
										}
									}
								}
								if (node.getNodeName().equals("fixedFiles")) {
									NodeList _l = node.getChildNodes();
									for (int j = 0; j < _l.getLength(); j++) {
										Node _n = _l.item(j);
										if (_n.getNodeName().equals("file")) {
											String fileName = _n.getTextContent();
											bug.addFixedFile(fileName);
										}
									}
								}
							}
						}
						
						list.add(bug);
					}
				}
			}
		} catch (Exception ex) {
			ex.printStackTrace();
		}
		return list;
	}
}