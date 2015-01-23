CREATE TABLE SF_INFO(SF_ID INT PRIMARY KEY AUTO_INCREMENT, SF_NAME VARCHAR(255), PROD_NAME VARCHAR(31));
CREATE TABLE SF_VER_INFO (SF_VER_ID INT PRIMARY KEY AUTO_INCREMENT, SF_ID INT, VER VARCHAR(15), COR_SET VARCHAR, LEN_SCORE DOUBLE);
CREATE TABLE SF_COR_INFO (SF_COR_ID INT PRIMARY KEY AUTO_INCREMENT, COR VARCHAR(255), PROD_NAME VARCHAR(31));
CREATE TABLE SF_ANALYSIS (SF_VER_ID INT, SF_COR_ID INT, TERM_CNT INT, INV_DOC_CNT INT, TF DOUBLE, IDF DOUBLE, VEC DOUBLE);

CREATE TABLE FUNC_INFO(FUNC_ID INT PRIMARY KEY AUTO_INCREMENT, FUNC_NAME VARCHAR(255), PROD_NAME VARCHAR(31));
CREATE TABLE FUNC_VER_INFO (FUNC_VER_ID INT PRIMARY KEY AUTO_INCREMENT, FUNC_ID INT, VER VARCHAR(15), COR_SET VARCHAR, LEN_SCORE DOUBLE);
CREATE TABLE FUNC_COR_INFO (FUNC_COR_ID INT PRIMARY KEY AUTO_INCREMENT, COR VARCHAR(255), PROD_NAME VARCHAR(31));
CREATE TABLE FUNC_ANALYSIS (FUNC_VER_ID INT, FUNC_COR_ID INT, TERM_CNT INT, INV_DOC_CNT INT, TF DOUBLE, IDF DOUBLE, VEC DOUBLE);

CREATE TABLE BUG_INFO(BUG_ID VARCHAR(31) PRIMARY KEY, PROD_NAME VARCHAR(31), FIXED_DATE DATETIME, COR_SET VARCHAR, STRACE_SET VARCHAR(2047), );
CREATE TABLE BUG_COR_INFO(BUG_COR_ID INT PRIMARY KEY AUTO_INCREMENT, COR VARCHAR(255), PROD_NAME VARCHAR(31));
CREATE TABLE BUG_ANALYSIS(BUG_ID VARCHAR(31), BUG_COR_ID INT, VEC DOUBLE);
CREATE TABLE BUG_FIX_INFO(BUG_ID VARCHAR(31), FIXED_SF_VER_ID INT, FIXED_FUNC_VER_ID INT);
CREATE TABLE SIMI_BUG_INFO(BUG_ID VARCHAR(31), SIMI_BUG_ID VARCHAR(31), SIMI_BUG_SCORE DOUBLE);
CREATE TABLE INT_ANALYSIS(BUG_ID VARCHAR(31), SF_VER_ID INT, VSM_SCORE DOUBLE, SIMI_SCORE DOUBLE, BL_SCORE DOUBLE, STRACE_SCORE DOUBLE, BLIA_SCORE DOUBLE);

CREATE TABLE COMM_INFO(COMM_ID VARCHAR(31) PRIMARY KEY, PROD_NAME VARCHAR(31), COMM_DATE DATETIME, DESC VARCHAR);
CREATE TABLE COMM_FILE_INFO(COMM_ID VARCHAR(31), SF_ID INT);
CREATE TABLE VER_INFO(VER VARCHAR(15) PRIMARY KEY, REL_DATE DATETIME);

CREATE TABLE EXP_INFO(TOP1 INT, TOP5 INT, TOP10 INT, MRR DOUBLE, MAP DOUBLE, PROD_NAME VARCHAR(31), ALG_NAME VARCHAR(31), ALG_DESC VARCHAR(255), EXP_DATE DATETIME);


SELECT A.SF_NAME, D.COR, C.TERM_CNT, C.INV_DOC_CNT, C.VEC
FROM SF_INFO A, SF_VER_INFO B, SF_ANALYSIS C, SF_COR_INFO D
WHERE A.SF_ID = B.SF_ID AND B.VER = 'v1.0' AND A.PROD_NAME = 'swt-3.1' AND C.SF_COR_ID = D.SF_COR_ID AND A.SF_NAME = 'org.eclipse.swt.internal.win32.NMCUSTOMDRAW.java' AND B.SF_VER_ID  = C.SF_VER_ID


SELECT A.BUG_ID, B.SF_NAME FROM BUG_FIX_INFO A, SF_INFO B, SF_VER_INFO C WHERE A.FIXED_SF_VER_ID = C.SF_VER_ID AND  B.SF_ID = C.SF_ID AND C.VER = 'v1.0' AND B.PROD_NAME = 'swt-3.1'


UPDATE SF_VER_INFO
SET TOT_CNT = 19
WHERE SF_ID IN (SELECT A.SF_ID FROM SF_INFO A, SF_VER_INFO B WHERE A.SF_ID = B.SF_ID AND A.PROD_NAME = 'swt-3.1'
AND A.SF_NAME = 'org.eclipse.swt.accessibility.ACC.java' AND B.VER = 'v1.0');

SELECT A.SF_NAME, B.TOT_CNT, B.LEN_SCORE FROM SF_INFO A, SF_VER_INFO B WHERE A.SF_ID = B.SF_ID AND A.PROD_NAME = 'swt-3.1'
AND B.VER = 'v1.0';

## Useful queries

SELECT A.BUG_ID, C.SF_NAME, A.VSM_SCORE
FROM INT_ANALYSIS A, SF_VER_INFO B, SF_INFO C
WHERE A.SF_VER_ID = B.SF_VER_ID AND B.SF_ID = C.SF_ID AND A.BUG_ID = 75739 ORDER BY B.SF_VER_ID

SELECT A.BUG_ID, B.COR, A.VEC
FROM BUG_ANALYSIS A, BUG_COR_INFO B
WHERE A.BUG_COR_ID = B.BUG_COR_ID

SELECT A.BUG_ID, C.SF_NAME, B.SF_VER_ID, A.VSM_SCORE, A.SIMI_SCORE
FROM INT_ANALYSIS A, SF_VER_INFO B, SF_INFO C
WHERE A.SF_VER_ID = B.SF_VER_ID AND B.SF_ID = C.SF_ID AND A.BUG_ID = 78548 AND A.SIMI_SCORE != 0.0 ORDER BY B.SF_VER_ID
