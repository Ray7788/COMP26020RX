#pragma once
#include <string>
#include <vector>
#include <memory>

/* The different types of documents stored in the library */
// typedef enum { DOC_NOVEL, DOC_COMIC, DOC_MAGAZINE } DocType;
enum DocType { DOC_NOVEL, DOC_COMIC, DOC_MAGAZINE };

/* Parent class for all types of documents */
class Document {
public:
  /* return the document type (abstract method) */
  virtual DocType getDocType() = 0;

  // add a virtual destructor 
  virtual ~Document();
  
  /* print the document attributes in a single line on the standard output
   * (abstract method), the format for the various document types is as
   * follows:
   * Novel, title: <title>, author: <author>, year: <year>, quantity: <quantity>
   * Comic, title: <title>, author: <author>, issue: <issue>, year: <year>,
   * quantity: <quantity> Magazine, title: <title>, issue: <issue>, year:
   * <year>, quantity: <quantity>
   */
  virtual void print() = 0;

  /* setters and getters */
  void updateTitle(std::string newTitle);
  void updateYear(int newYear);
  void updateQuantity(int newQuantity);
  std::string getTitle();
  int getYear();
  int getQuantity();

  /* Used when someone tries to borrow a document, should return true on success
   * and false on failure */
  bool borrowDoc();

  /* Used when someone returns a document */
  void returnDoc();

protected:
  /* These need to be protected to be inherited by the child classes */
  std::string _title;  // document title
  int _year;     // year of parution
  int _quantity; // quantity held in the library, should be updated on
                 // borrow (-1) and return (+1)
};

class Novel : public Document {
public:
  Novel(std::string title, std::string author, int year, int quantity);
  ~Novel();
  DocType getDocType();
  void print();

  /* getters and setters */
  void updateAuthor(std::string newAuthor);
  std::string getAuthor();

private:
  /* In addition to the base Document's attributes, a novel has an author */
  std::string _author;
};

class Comic : public Document {
public:
  Comic(std::string title, std::string uthor, int issue, int year,
        int quantity);
  ~Comic();
  DocType getDocType();
  void print();

  /* getters, setters */
  void updateAuthor(std::string newAuthor);
  void updateIssue(int newIssue);
  std::string getAuthor();
  int getIssue();

private:
  /* In addition to the base Document's attributes, a comic has an author as
   * well as an issue number */
  std::string _author;
  int _issue;
};

class Magazine : public Document {
public:
  Magazine(std::string title, int issue, int year, int quantity);
  ~Magazine();
  DocType getDocType();
  void print();

  /* getters, setters */
  void updateIssue(int newIssue);
  int getIssue();

private:
  /* In addition to the base Document's attributes, a magazine has an issue
   * number */
  int _issue;
};

/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/* One instance of that class represents a library */
class Library {
public:
  Library();

  /* print the entire library on the standard output, one line per document,
   * in the order they were inserted in the library, using the print()
   * methods implemented by the document objects */
  void print();

  /* Dump the library in a CSV file. The format is:
   * 1 line per file:
   * <document type>,<title>,<author>,<issue>,<year>,<quantity>
   * A field not relevant for a given document type (e.g. issue for novel)
   * is left blank. Return true on success, false on failure. */
  bool dumpCSV(std::string filename);

  /* search for a document in the library, based on the title. We assume that
   * a title identifies uniquely a document in the library, i.e. there cannot
   * be 2 documents with the same title. Returns a pointer to the document if
   * found, NULL otherwise */
  Document *searchDocument(std::string title);

  /* Add/delete a document to/from the library, return true on success and
   * false on failure.  */
  bool addDocument(DocType t, std::string title, std::string author, int issue,
                  int year, int quantity);
  bool addDocument(Document *d);
  bool addDocument(std::shared_ptr<Document> d);
  bool delDocument(std::string title);

  /* Count the number of document of a given type present in the library */
  int countDocumentOfType(DocType t);

  /* Borrow/return documents, return true on success, false on failure */
  bool borrowDoc(std::string title);
  bool returnDoc(std::string title);

private:
  /* Holds all documents in the library */
  // Document *_docs[32 * 1024];
  std::vector<std::shared_ptr<Document>> _docs;
  int _docs_sz;
};
