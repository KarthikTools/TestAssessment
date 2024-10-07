# **Creating an End-to-End Testing Framework with Postman, Postman SDK, and Newman**

## **Table of Contents**

1. [Introduction](#introduction)
2. [Overview of Tools and Technologies](#overview)
3. [Setting Up the Environment](#setup-environment)
4. [Creating API Requests in Postman](#creating-requests)
5. [Writing Tests in Postman](#writing-tests)
6. [Exporting Collections and Environments](#exporting)
7. [Setting Up the Node.js Project](#nodejs-project)
8. [Running the Collection with Newman](#running-newman)
9. [Integrating Database Verification](#database-verification)
10. [Running and Debugging the Tests](#running-debugging)
11. [Generating Test Reports](#generating-reports)
12. [Best Practices and Considerations](#best-practices)
13. [Conclusion](#conclusion)

---

<a name="introduction"></a>
## **1. Introduction**

This document provides a comprehensive guide on how to create an end-to-end testing framework using **Postman**, **Postman SDK**, and **Newman**. It demonstrates how to automate API testing, integrate with external data sources, perform database verification, and generate detailed test reports.

This framework enables teams to:

- **Automate API Testing**: Streamline testing processes by automating API requests and validations.
- **Integrate with Databases**: Verify API operations by checking data directly in the database.
- **Utilize External Data Sources**: Run tests with multiple data sets using CSV files.
- **Generate Reports**: Produce comprehensive reports for analysis and stakeholder communication.

---

<a name="overview"></a>
## **2. Overview of Tools and Technologies**

### **Postman**

A popular API client that allows you to design, test, and document APIs. Features include:

- Creating and organizing API requests.
- Writing tests using JavaScript.
- Managing environments and variables.

### **Postman SDK**

A collection of libraries that enable programmatic access to Postman entities, such as collections and environments. Used for:

- Advanced scripting and customization.
- Integrating Postman collections into CI/CD pipelines.

### **Newman**

A command-line collection runner for Postman. It allows you to:

- Run Postman collections from the terminal.
- Integrate with build systems and continuous integration servers.
- Generate reports in various formats.

### **Node.js**

A JavaScript runtime built on Chrome's V8 engine. Used for:

- Running custom scripts to orchestrate test runs.
- Integrating database operations.

### **Database (MySQL)**

Used to store and verify data inserted via API calls.

---

<a name="setup-environment"></a>
## **3. Setting Up the Environment**

### **Prerequisites**

- **Node.js** installed on your machine.
- **Postman** application installed.
- **MySQL** database access.
- **Visual Studio Code** or another code editor.

### **Install Newman**

Open your terminal and run:

```bash
npm install -g newman
```

### **Install Necessary Node.js Packages**

Create a project directory and initialize npm:

```bash
mkdir api-testing-framework
cd api-testing-framework
npm init -y
```

Install required packages:

```bash
npm install newman newman-reporter-html mysql dotenv --save
```

---

<a name="creating-requests"></a>
## **4. Creating API Requests in Postman**

### **Step 1: Create a New Collection**

- Open Postman and click **"New Collection"**.
- Name your collection (e.g., **"API Testing Framework"**).

### **Step 2: Add a Request to the Collection**

- Set the HTTP method (e.g., **POST**).
- Enter the API endpoint URL.
- Under **"Authorization"**, select **"Basic Auth"** and provide the username and password.
- Under **"Headers"**, add `Content-Type: application/json`.
- Under **"Body"**, select **"raw"** and choose **"JSON"** format.

### **Step 3: Use Variables in the Request Body**

Replace static values with variables:

```json

```

---

<a name="writing-tests"></a>
## **5. Writing Tests in Postman**

### **Step 1: Access the Tests Tab**

- Click on the **"Tests"** tab in your request.

### **Step 2: Write Test Scripts**

**Example Test Script:**



---

<a name="exporting"></a>
## **6. Exporting Collections and Environments**

### **Step 1: Create an Environment**

- Click on **"Environments"** > **"Create Environment"**.
- Add necessary variables (e.g., `baseUrl`, `username`, `password`).

### **Step 2: Export the Collection and Environment**

- **Export Collection**:
  - Right-click on the collection and select **"Export"**.
  - Choose **Collection v2.1** format.
  - Save as `collection.json` in your project directory.

- **Export Environment**:
  - Go to **"Manage Environments"**.
  - Select your environment and click **"Export"**.
  - Save as `environment.json` in your project directory.

---

<a name="nodejs-project"></a>
## **7. Setting Up the Node.js Project**

### **Step 1: Create `data.csv`**



### **Step 2: Create `.env` File**

Store database credentials:



### **Step 3: Create `runTests.js`**

```javascript
const newman = require('newman');
const verifyDatabase = require('./verifyDatabase');
const path = require('path');

const recordIds = [];

newman.run({
  collection: require('./collection.json'),
  environment: require('./environment.json'),
  iterationData: path.join(__dirname, 'data.csv'),
  reporters: ['cli', 'html'],
  reporter: {
    html: {
      export: './newman-report.html',
    },
  },
})
.on('request', function (err, args) {
  if (err) {
    console.error('Error in request event:', err);
  } else {
    const response = args.response;
    const body = response.stream.toString('utf8');

    try {
      const jsonData = JSON.parse(body);
      const recordId = jsonData.record_id;
      if (recordId && !recordIds.includes(recordId)) {
        recordIds.push(recordId);
      }
    } catch (e) {
      console.error('Error parsing response body:', e.message);
    }
  }
})
.on('done', function (err) {
  if (err) {
    console.error('Collection run encountered an error:', err);
  } else {
    console.log('Collection run complete!');
    // Perform database verification
    recordIds.forEach(recordId => {
      verifyDatabase(recordId, function (error) {
        if (error) {
          console.error(`Database verification failed for Record ID: ${recordId}:`, error.message);
        } else {
          console.log(`Database verification passed for Record ID: ${recordId}`);
        }
      });
    });
  }
});
```

### **Step 4: Create `verifyDatabase.js`**

```javascript
const mysql = require('mysql');
require('dotenv').config();

module.exports = function (recordId, callback) {
  const connection = mysql.createConnection({
   
  });

  connection.connect(function (err) {
    if (err) {
      console.error('Database connection failed:', err.message);
      return callback(err);
    }

    const query = 'SELECT * FROM your_table WHERE record_id = ?';
    connection.query(query, [recordId], function (error, results) {
      connection.end();

      if (error) {
        console.error('Query execution failed:', error.message);
        return callback(error);
      }

      if (results.length > 0) {
        console.log('Record found:', results[0]);
        // Additional assertions can be added here
        callback(null);
      } else {
        console.error('Record not found in the database.');
        callback(new Error('Record not found in the database.'));
      }
    });
  });
};
```

---

<a name="running-newman"></a>
## **8. Running the Collection with Newman**

### **Step 1: Run the Test Script**

Open your terminal and run:

```bash
node runTests.js
```

### **Step 2: Observe the Output**

- Newman will execute the Postman collection.
- The `request` event captures `record_id` from the response.
- After the collection run, database verification is performed.

---

<a name="database-verification"></a>
## **9. Integrating Database Verification**

### **Step 1: Verify Database Connection**

Ensure that `verifyDatabase.js` can connect to your database independently.

Create `testVerifyDatabase.js`:

```javascript
const verifyDatabase = require('./verifyDatabase');

const testRecordId = 'sample_record_id';

verifyDatabase(testRecordId, function (error) {
  if (error) {
    console.error('Database verification failed:', error.message);
  } else {
    console.log('Database verification succeeded.');
  }
});
```

Run the script:

```bash
node testVerifyDatabase.js
```

### **Step 2: Implement Assertions**

In `verifyDatabase.js`, add assertions to verify data integrity.

---

<a name="running-debugging"></a>
## **10. Running and Debugging the Tests**

### **Step 1: Use Console Logs**

Add `console.log()` statements in your scripts to debug issues.

### **Step 2: Use Node.js Debugger**

Run your script with the debugger:

```bash
node --inspect-brk runTests.js
```

Attach a debugger (e.g., Chrome DevTools) to step through the code.

---

<a name="generating-reports"></a>
## **11. Generating Test Reports**

Newman can generate HTML reports for your test runs.

- Reports are configured in `runTests.js` under the `reporter` section.
- The report is saved as `newman-report.html`.
- Open the report in a web browser to view detailed results.

---

<a name="best-practices"></a>
## **12. Best Practices and Considerations**

### **Security**

- Store sensitive information like database credentials securely.
- Use environment variables or a `.env` file (ensure it's in `.gitignore`).

### **Error Handling**

- Implement robust error handling in your scripts.
- Validate inputs and handle exceptions gracefully.

### **Version Control**

- Use Git for version control.
- Exclude `node_modules`, `.env`, and reports from your repository.

### **Code Quality**

- Use linters like ESLint to maintain code quality.
- Follow consistent coding standards.

### **Scalability**

- Organize your tests and scripts for scalability.
- Consider using a test runner like Mocha or Jest for larger projects.

---

<a name="conclusion"></a>
## **13. Conclusion**

By integrating Postman, Postman SDK, and Newman, you can create a powerful end-to-end testing framework that:

- Automates API testing with data-driven approaches.
- Validates API responses and ensures data integrity in the database.
- Generates comprehensive reports for stakeholders.
- Enhances the efficiency and reliability of your testing processes.

This framework can be integrated into CI/CD pipelines, allowing for continuous testing and rapid feedback during development cycles.

