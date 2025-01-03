#include "library.h"

#include <cassert>
///////////////////
#include <fstream>
#include <iostream>
#include <string>
#include <vector>
#include <memory>

Document::~Document() {}

void Document::updateTitle(const std:: string newTitle) {
  _title = newTitle;
}

void Document::updateYear(int newYear) { _year = newYear; }
void Document::updateQuantity(int newQuantity) { _quantity = newQuantity; }
std::string Document::getTitle() { return _title; }
int Document::getYear() { return _year; }
int Document::getQuantity() { return _quantity; }

bool Document::borrowDoc() {
  if (_quantity > 0) {
    _quantity--;
    return true;
  }
  return false;
}

void Document::returnDoc() { _quantity++; }
/*-------------------------------------------------------------------------------------------------*/

Novel::Novel(const std:: string title, const std:: string author, int year, int quantity) {
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

void Novel::updateAuthor(const std:: string newAuthor) {
  _author = newAuthor;
}

std::string Novel::getAuthor() { return _author; }
/*-------------------------------------------------------------------------------------------------*/

Comic::Comic(const std:: string title, const std:: string author, int issue, int year, int quantity) {
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

void Comic::updateAuthor(const std:: string newAuthor) {
  _author = newAuthor;
}

void Comic::updateIssue(int newIssue) { _issue = newIssue; }
std::string Comic::getAuthor() { return _author; }
int Comic::getIssue() { return _issue; }
/*-------------------------------------------------------------------------------------------------*/

Magazine::Magazine(const std:: string title, int issue, int year, int quantity) {
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

bool Library::addDocument(DocType t, const std:: string title, const std:: string author,
                         int issue, int year, int quantity) {

  std::shared_ptr<Document> d;
  switch (t) {
  case DOC_NOVEL: {
    d = std::make_shared<Novel> (title, author, year, quantity);
    break;
  }

  case DOC_COMIC: {
    d = std::make_shared<Comic> (title, author, issue, year, quantity);
    break;
  }

  case DOC_MAGAZINE: {
    d = std::make_shared<Magazine> (title, issue, year, quantity);
    break;
  }

  default:
    return false;
  }
  return addDocument(d);
  return true;
}

bool Library::addDocument(Document *d) {
  for(auto& _doc: _docs){
    if (!(_doc->getTitle()).compare(d->getTitle())){
      return false;
    }
  }

  // change to smart pointer
  auto smartd = std::shared_ptr<Document>(d);
  
  _docs.push_back(smartd);
  _docs_sz++;
  return true;
}

//  overload addDocument
bool Library::addDocument(std::shared_ptr<Document> d) {
  for(auto& _doc: _docs){
    if (!(_doc->getTitle()).compare(d->getTitle())){
      return false;
    }
  }

  _docs.push_back(d);
  _docs_sz++;
  return true;
}

bool Library::delDocument(const std:: string title) {
  for(auto iter = _docs.begin(); iter != _docs.end(); iter++){
    if (!((*iter)->getTitle()).compare(title)) {
      _docs.erase(iter);
      return true;
      break;
    }
  }


  return false;  
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

// return a raw pointer
Document *Library::searchDocument(const std:: string title) {
  for(auto& _doc:_docs){
    if (!(_doc->getTitle()).compare(title)){ 
      return _doc.get();
    }
  }
  return NULL;
}

void Library::print() {
  for(auto iter = _docs.begin(); iter != _docs.end(); iter++){
    (*iter)->print();
  }
}

bool Library::borrowDoc(const std:: string title) {
  Document *d = searchDocument(title);
  if (d){
    return d->borrowDoc();
    return true;
  }
  return false;
}

bool Library::returnDoc(const std:: string title) {
  Document *d = searchDocument(title);
  if (d) {
    d->returnDoc();
    return true;
  }
  return false;
}

bool Library::dumpCSV(const std:: string filename) {
  std::ofstream ofs;
  ofs.open(filename);

  if (!ofs){
    return false;
  }

  for(auto& _doc:_docs){

    switch (_doc->getDocType()) {
    case DOC_NOVEL: {
      auto n = std::dynamic_pointer_cast<Novel>(_doc);
      ofs << "novel," << n->getTitle() << "," << n->getAuthor() << ",," << n->getYear() << "," << n->getQuantity() << std::endl;
      break;
    }

    case DOC_COMIC: {
      auto c = std::dynamic_pointer_cast<Comic>(_doc);
      ofs << "comic," << c->getTitle() << "," << c->getAuthor() << "," << c->getIssue() << "," << c->getYear() << "," << c->getQuantity() << std::endl;
      break;
    }

    case DOC_MAGAZINE: {
      auto m = std::dynamic_pointer_cast<Magazine>(_doc);
      ofs << "magazine," << m->getTitle() << ",," << m->getIssue() << "," << m->getYear() << "," << m->getQuantity() << std::endl;
      break;
    }

    default:
      return false;
    }

  }

  ofs.close();
  return true;
}
