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
#include <iostream>
#include <string>
#include <vector>
#include <memory>


void Document::updateTitle(std::string newTitle) {
  // free(_title);
  // _title = (char *)malloc((strlen(newTitle) + 1) * sizeof(char));
  // assert(_title);
  // strcpy(_title, newTitle);
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
  // _title = (char *)malloc((strlen(title) + 1) * sizeof(char));
  // _author = (char *)malloc((strlen(author) + 1) * sizeof(char));
  // assert(_title && _author);
  // strcpy(_title, title);
  // strcpy(_author, author);
  _title = title;
  _author = author;
  _year = year;
  _quantity = quantity;
}

Novel::~Novel() {
  // free(_author);
  // free(_title);
}

DocType Novel::getDocType() { return DOC_NOVEL; }

void Novel::print() {
  std::cout << "Novel, title: " << _title << ", author: " << _author << ", year: "<< _year << ", quantity: "<< _quantity << "\n";
  // printf("Novel, title: %s, author: %s, year: %d, quantity: %d\n", _title,
  //        _author, _year, _quantity);
}

void Novel::updateAuthor(std::string newAuthor) {
  // free(_author);
  // _author = (char *)malloc((strlen(newAuthor) + 1) * sizeof(char));
  // assert(_author);
  // strcpy(_author, newAuthor);
  _author = newAuthor;
}

std::string Novel::getAuthor() { return _author; }
/*-------------------------------------------------------------------------------------------------*/

Comic::Comic(std::string title, std::string author, int issue, int year, int quantity) {
  // _title = (char *)malloc((strlen(title) + 1) * sizeof(char));
  // _author = (char *)malloc((strlen(author) + 1) * sizeof(char));
  // assert(_author && _title);
  // strcpy(_title, title);
  // strcpy(_author, author);
  _title = title;
  _author = author;
  _year = year;
  _quantity = quantity;
  _issue = issue;
}

Comic::~Comic() {
  // free(_author);
  // free(_title);
}

DocType Comic::getDocType() { return DOC_COMIC; }

void Comic::print() {
  std::cout << "Comic, title: " << _title << ", author: " << ", year: "<< _year << ", quantity: "<< _quantity << "\n";
  // printf("Comic, title: %s, author: %s, issue: %d, year: %d, quantity: %d\n",
  //        _title, _author, _issue, _year, _quantity);
}

void Comic::updateAuthor(std::string newAuthor) {
  // free(_author);
  // _author = (char *)malloc((strlen(newAuthor) + 1) * sizeof(char));
  // assert(_author);
  // strcpy(_author, newAuthor);
  _author = newAuthor;
}

void Comic::updateIssue(int newIssue) { _issue = newIssue; }
std::string Comic::getAuthor() { return _author; }
int Comic::getIssue() { return _issue; }
/*-------------------------------------------------------------------------------------------------*/

Magazine::Magazine(std::string title, int issue, int year, int quantity) {
  // _title = (char *)malloc((strlen(title) + 1) * sizeof(char));
  // assert(_title);
  // strcpy(_title, title);
  _title = title;
  _year = year;
  _quantity = quantity;
  _issue = issue;
}

Magazine::~Magazine() { 
  // free(_title);
 }

DocType Magazine::getDocType() { return DOC_MAGAZINE; }

void Magazine::print() {
  std::cout << "Magazine, title: " << _title << ", issue: " << _issue << ", year: "<< _year << ", quantity: "<< _quantity << "\n";
  // printf("Magazine, title: %s, issue: %d, year: %d, quantity: %d\n", _title,
  //        _issue, _year, _quantity);
}

void Magazine::updateIssue(int newIssue) { _issue = newIssue; }
int Magazine::getIssue() { return _issue; }

/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------*/

Library::Library() { _docs_sz = 0; };

int Library::addDocument(DocType t, std::string title, std::string author,
                         int issue, int year, int quantity) {
  // Document *d;
  switch (t) {
  case DOC_NOVEL: {
    // d = (Document *)new Novel(title, author, year, quantity);

    auto d(std::make_unique<Document>(title, author, year, quantity));
    std::unique_ptr<Document> d(new Novel(title, author, year, quantity));
    return addDocument(d);
    break;
  }

  case DOC_COMIC: {
    // d = (Document *)new Comic(title, author, issue, year, quantity);
    std::unique_ptr<Document> d(new Comic(title, author, issue, year, quantity));
    return addDocument(*d);
    break;
  }

  case DOC_MAGAZINE: {
    // d = (Document *)new Magazine(title, issue, year, quantity);
    std::unique_ptr<Document> d(new Magazine(title, issue, year, quantity));
    return addDocument(*d);
    break;
  }

  default:
    return 0;
  }
}

int Library::addDocument(Document &d) {
  for (int i = 0; i < _docs_sz; i++){
    // if (!strcmp(_docs[i]->getTitle(), d->getTitle()))
    if (!(_docs[i]->getTitle()).compare(d.getTitle())){
      return 0;
    }
  }  
  
  values.push_back(d);
  _docs_sz++;
  // _docs[_docs_sz++] = d;
  return 1;
}

int Library::delDocument(std::string title) {
  // int index = -1;
  for (int i = 0; i < _docs_sz; i++)
    // if (!strcmp(_docs[i]->getTitle(), title)) {
    if ((_docs[i]->getTitle()).compare(title)) {
      values.erase(values.begin()+i);
      return 1;
    }


    // if (index != -1) {
    //   free(_docs[index]);
    //   for (int i = index + 1; i < _docs_sz; i++){
    //     _docs[i - 1] = _docs[i];
    //     _docs_sz--;
    //   }
    //   return 1;
    // }

  return 0;
}

int Library::countDocumentOfType(DocType t) {
  int res = 0;

  for (int i = 0; i < _docs_sz; i++){
    if (_docs[i]->getDocType() == t){
      res++;
    }
  }

  return res;
}

Document *Library::searchDocument(std::string title) {
  for (int i = 0; i < _docs_sz; i++){
    // if (!strcmp(_docs[i]->getTitle(), title))
    if (!(_docs[i]->getTitle()).compare(title)){ 
      return *_docs[i];
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
  if (&d) {
    &d->returnDoc();
    return 1;
  }
  return 0;
}

int Library::dumpCSV(std::string filename) {
  // char line[128];
  std::string line;
  int bytes_written;

  std::ofstream ofs;
  ofs.open(filename);
  // ofs.open(filename, ofs::in | ios::out | ios::trunc);
  // int fd = open(filename, O_WRONLY | O_CREAT | O_TRUNC, S_IRUSR | S_IWUSR);
  if (!ofs){
    return 0;
  }

  for (int i = 0; i < _docs_sz; i++) {
    Document &d = _docs[i];

    switch (d->getDocType()) {
    case DOC_NOVEL: {
      Novel *n = (Novel *)&d;
      ofs << "novel" << n->getTitle() << "," << n->getAuthor() << "," << n->getYear() << "," << n->getQuantity() << std::endl;
      // sprintf(line, "novel,%s,%s,,%d,%d\n", n->getTitle(), n->getAuthor(),
      //         n->getYear(), n->getQuantity());
      break;
    }

    case DOC_COMIC: {
      Comic *c = (Comic *)&d;
      ofs << "comic" << n->getTitle() << "," << n->getAuthor() << "," << c->getIssue() << "," << n->getYear() << "," << << n->getQuantity() << std::endl;
      // sprintf(line, "comic,%s,%s,%d,%d,%d\n", c->getTitle(), c->getAuthor(),
      //         c->getIssue(), c->getYear(), c->getQuantity());
      break;
    }

    case DOC_MAGAZINE: {
      Magazine *m = (Magazine *)&d;
      ofs << "magazine" << m->getTitle() << "," << m->getIssue() << "," << m->getYear() << "," << m->getQuantity() << std::endl;
      // sprintf(line, "magazine,%s,,%d,%d,%d\n", m->getTitle(), m->getIssue(),
      //         m->getYear(), m->getQuantity());
      break;
    }

    default:
      return 0;
    }

    // bytes_written = write(fd, line, strlen(line));
    // if (bytes_written != strlen(line))
      // return 0;
  }

  close(fd);
  return 1;
}
