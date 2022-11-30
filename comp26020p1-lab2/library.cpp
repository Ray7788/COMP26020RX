#include "library.h"

#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>

#include <cassert>
///////////////////
#include <fstream>
#include <iostream>
#include <string>
#include <vector>
#include <memory>


void Document::updateTitle(std::string newTitle) {
  _title = newTitle;
}

void Document::updateYear(int newYear) { _year = newYear; }
void Document::updateQuantity(int newQuantity) { _quantity = newQuantity; }
std::string Document::getTitle() { return _title; }
int Document::getYear() { return _year; }
int Document::getQuantity() { return _quantity; }

int Document::borrowDoc() {
  if (_quantity > 0) {
    _quantity--;
    return 1;
  }
  return 0;
}

void Document::returnDoc() { _quantity++; }
/*-------------------------------------------------------------------------------------------------*/

Novel::Novel(std::string title, std::string author, int year, int quantity) {
  _title = title;
  _author = author;
  _year = year;
  _quantity = quantity;
}

Novel::~Novel() {
}

DocType Novel::getDocType() { return DOC_NOVEL; }

void Novel::print() {
  std::cout << "Novel, title: " << _title << ", author: " << _author << ", year: "<< _year << ", quantity: "<< _quantity << "\n";
}

void Novel::updateAuthor(std::string newAuthor) {
  _author = newAuthor;
}

std::string Novel::getAuthor() { return _author; }
/*-------------------------------------------------------------------------------------------------*/

Comic::Comic(std::string title, std::string author, int issue, int year, int quantity) {
  _title = title;
  _author = author;
  _year = year;
  _quantity = quantity;
  _issue = issue;
}

Comic::~Comic() {
}

DocType Comic::getDocType() { return DOC_COMIC; }

void Comic::print() {
  std::cout << "Comic, title: " << _title << ", author: " << _author << ", issue: " << _issue << ", year: "<< _year << ", quantity: "<< _quantity << "\n";
}

void Comic::updateAuthor(std::string newAuthor) {
  _author = newAuthor;
}

void Comic::updateIssue(int newIssue) { _issue = newIssue; }
std::string Comic::getAuthor() { return _author; }
int Comic::getIssue() { return _issue; }
/*-------------------------------------------------------------------------------------------------*/

Magazine::Magazine(std::string title, int issue, int year, int quantity) {
  _title = title;
  _year = year;
  _quantity = quantity;
  _issue = issue;
}

Magazine::~Magazine() { 
 }

DocType Magazine::getDocType() { return DOC_MAGAZINE; }

void Magazine::print() {
  std::cout << "Magazine, title: " << _title << ", issue: " << _issue << ", year: "<< _year << ", quantity: "<< _quantity << "\n";
}

void Magazine::updateIssue(int newIssue) { _issue = newIssue; }
int Magazine::getIssue() { return _issue; }

/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------*/

Library::Library() { _docs_sz = 0; };

int Library::addDocument(DocType t, std::string title, std::string author,
                         int issue, int year, int quantity) {
  // Document *d;
  std::shared_ptr<Document> d;
  switch (t) {
  case DOC_NOVEL: {
    // d = (Document *)new Novel(title, author, year, quantity);

    d = std::make_shared<Novel> (title, author, year, quantity);
    break;
  }

  case DOC_COMIC: {
    // d = (Document *)new Comic(title, author, issue, year, quantity);

    d = std::make_shared<Comic> (title, author, issue, year, quantity);
    break;
  }

  case DOC_MAGAZINE: {
    // d = (Document *)new Magazine(title, issue, year, quantity);

    d = std::make_shared<Magazine> (title, issue, year, quantity);
    break;
  }

  default:
    return 0;
  }
  return addDocument(d);
}

int Library::addDocument(Document *d) {
  for(auto& _doc: _docs){
    if (!(_doc->getTitle()).compare(d->getTitle())){
      return 0;
    }
  }

  auto sd = std::shared_ptr<Document>(d);
  
  _docs.push_back(sd);
  _docs_sz++;
  return 1;
}

//  overload add iterator
int Library::addDocument(std::shared_ptr<Document> d) {
  for(auto& _doc: _docs){
    if (!(_doc->getTitle()).compare(d->getTitle())){
      return 0;
    }
  }

  _docs.push_back(d);
  _docs_sz++;
  return 1;
}

int Library::delDocument(std::string title) {
  int index = -1;

  // for(auto& _doc:_docs){
  //   if(!(_doc->getTitle()).compare(title)){
  //     index = i;
  //     break;
  //   }
  // }
  for (int i = 0; i < _docs_sz; i++){
    if (!(_docs[i]->getTitle()).compare(title)) {
      index = i;
      break;
    }
  }

  if (index != -1) {
    _docs.erase(_docs.begin()+index);
    _docs_sz--;
    return 1;
  }

  return 0;  
}

int Library::countDocumentOfType(DocType t) {
  int res = 0;

  for(auto& _doc:_docs){
    if (_doc->getDocType() == t){
      res++;
    }
  }

  return res;
}

Document *Library::searchDocument(std::string title) {
  for(auto& _doc:_docs){
    if (!(_doc->getTitle()).compare(title)){ 
      return _doc.get();
    }
  }
  return NULL;
}

void Library::print() {
  for (int i = 0; i < _docs_sz; i++){
    _docs[i]->print();
  }
}

int Library::borrowDoc(std::string title) {
  Document *d = searchDocument(title);
  if (d){
    return d->borrowDoc();
  }
  return 0;
}

int Library::returnDoc(std::string title) {
  Document *d = searchDocument(title);
  if (d) {
    d->returnDoc();
    return 1;
  }
  return 0;
}

int Library::dumpCSV(std::string filename) {
  std::ofstream ofs;
  ofs.open(filename);

  if (!ofs){
    return 0;
  }

  for(auto& _doc:_docs){
    // Document *d = _doc;

    switch (_doc->getDocType()) {
    case DOC_NOVEL: {
      // Novel *n = (Novel *)d;
      auto n = std::dynamic_pointer_cast<Novel>(_doc);
      ofs << "novel," << n->getTitle() << "," << n->getAuthor() << ",," << n->getYear() << "," << n->getQuantity() << std::endl;
      break;
    }

    case DOC_COMIC: {
      // Comic *c = (Comic *)d;
      // Comic* c = dynamic_cast<Comic*> (d);
      auto c = std::dynamic_pointer_cast<Comic>(_doc);
      ofs << "comic," << c->getTitle() << "," << c->getAuthor() << "," << c->getIssue() << "," << c->getYear() << "," << c->getQuantity() << std::endl;
      break;
    }

    case DOC_MAGAZINE: {
      // Magazine *m = (Magazine *)d;
      auto m = std::dynamic_pointer_cast<Magazine>(_doc);
      ofs << "magazine," << m->getTitle() << ",," << m->getIssue() << "," << m->getYear() << "," << m->getQuantity() << std::endl;
      break;
    }

    default:
      return 0;
    }

  }

  ofs.close();
  return 1;
}
