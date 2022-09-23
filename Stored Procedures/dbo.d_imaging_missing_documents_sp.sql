SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_imaging_missing_documents_sp]
AS

/*****************************************************************
NAME: d_imaging_missing_documents_sp
FILE: tmwsp_d_imaging_missing_documents_sp.sql

PURPOSE: Return a resultset for the FSS image rescan list

Revision History:

Date      Name          Reason
--------  ------------  -------------------------------
14/04/05  kdecelle      Initial creation
29/08/07  ehblack       - Require a new doctype, FTR. Required for any order
                          with an LWU or LFA.
                        - Do not include cancelled orders
06/09/07  ehblack       QA Changes
20/10/07  rpalmer       - CC7192 Changes noted below

EXECUTION and INPUTS:
EXEC d_imaging_missing_documents_sp 

   CHANGE CC7192A NOTES
 * --------------------------------------------------
 * METHODOLOGY:
 * 
 * This query was performing poorly because of some issues with the 
 * data in the table and where the aggrate function (group-by) was
 * being performed in the previous stored procedure.  This query
 * redesign is designed on the premise that the most intensive
 * operations should be performed on the least amount of data even
 * if that requires working with a larger data set and using more
 * low-intensity operations to refine that data.  
 * 
 * DECISION LOGIC:
 * 
 * HAS      HAS     HAS     SHOW MESSAGE
 * LWU      LFA     FTR     
 * --------------------------------------------------
 *  Y        N       N      LFA, FTR MISSING
 *  Y        N       Y      LFA MISSING      
 *  Y        Y       N      FTR MISSING IF LOAD_DATE > FTR DATE      
 *  Y        Y       Y      **NO MESSAGE
 *  N        N       N      **NO MESSAGE      
 *  N        N       Y      LFA MISSING
 *  N        Y       N      FTR MISSING IF LOAD_DATE > FTR DATE
 *  N        Y       Y      **NO MESSAGE
 *
 * PROCEDURE:
 *  
 * Step 1: Load all documents that have an LWU but are missing a LFA
 * into a temporary table -- ignoring duplicates
 * Step 2: load all documents that have a LFA but are missing an FTR
 * into the temporary table -- ignoring duplicates
 * Step 3: Load all documents that have an FTR but are missing an LFA
 * into the temporary table
 * Step 4: move the list of orders into a processing temporary table
 * using a group-by clause to eliminate duplicate order numbers.  Mark all 
 * documents as missing both a FTR and LFA
 * Step 5: find documents that have a LFA and mark them as having been found
 * Step 6: find documents that have an FTR and mark them as having been found
 * 
 * HAS      HAS     HAS     COVERED
 * LWU      LFA     FTR     BY
 * --------------------------------------------------
 *  Y        N       N      STEP2
 *  Y        N       Y      STEP2     
 *  Y        Y       N      STEP1    
 *  N        N       Y      STEP3
 *  N        Y       N      STEP1
 * 
 */
  

-- this temporary table will hold the resluts of the queries
-- including duplicate ord_hdrnumbers

CREATE TABLE #ord_tmp
(
    ord_hdrnumber   int

)      
  
-- This temp table contains the M AGGREGATE data for the report            
create table #allorders
(
    ord_hdrnumber   int,
    pw_ident        int,
    lfa_found       char(1) null,
    ftr_found       char(1) null
)
 

-- The dates here are the effective dates that the FTR document is required
declare
    @usa_date datetime,
    @cda_date datetime,
    @ord_hdrnumber int


-- Get the effective Dates from the general info table.
select  @usa_date   = gi_date1,
        @cda_date   = gi_date2
from    generalinfo
where   gi_name     = 'IMAGING_FTR_REQUIRED'
           
           

    
-- STEP 1: Find all the orders that have an LFA but
--         do not have FTR and are after the go-live date for FTRs
--         Select the orders for American branches first
--         and Canadian branches second.

-- American branches
INSERT  into #ord_tmp (ord_hdrnumber)
SELECT  imp.ord_hdrnumber
FROM    paperwork imp
inner join orderheader on imp.ord_hdrnumber=orderheader.ord_hdrnumber
WHERE   
        isnull(imp.ord_hdrnumber,0)>0 and 
        imp.abbr =  'LFA' AND
        imp.pw_imaged='Y' and
        orderheader.ord_origin_earliestdate>= @usa_date AND
        orderheader.ord_revtype1 like '%U' AND 
        NOT EXISTS
            (
                    SELECT 1 FROM paperwork ftr
                    WHERE   ftr.ord_hdrnumber = imp.ord_hdrnumber AND
                            ftr.abbr = 'FTR' AND
                            ftr.pw_imaged='Y' and
                            ftr.ord_hdrnumber  > 0
            ) 
        

-- Canadian Branches

INSERT  into #ord_tmp (ord_hdrnumber)
SELECT  imp.ord_hdrnumber
FROM    paperwork imp
inner join orderheader on imp.ord_hdrnumber=orderheader.ord_hdrnumber
WHERE   
        isnull(imp.ord_hdrnumber,0)>0 and 
        imp.abbr =  'LFA' AND
        imp.pw_imaged='Y' and
        orderheader.ord_origin_earliestdate>= @cda_date AND
        orderheader.ord_revtype1 like '%C' AND 
        NOT EXISTS
            (
                    SELECT 1 
                    FROM 
                        paperwork ftr
                    WHERE   ftr.ord_hdrnumber = imp.ord_hdrnumber AND
                            ftr.abbr = 'FTR' AND
                            ftr.pw_imaged='Y' and
                            ftr.ord_hdrnumber  > 0
            ) 
        

-- STEP 2:  Find all the orders where an LWU exists but there is no LFA.
--          Because some orders get scanned in with a '0' order header number
--          exclude these items with the ord_hrnumber >= 1 clause.

INSERT INTO #ord_tmp
SELECT  ord_hdrnumber
FROM    paperwork imp
WHERE   
        imp.abbr =  'LWU' AND
        imp.pw_imaged='Y' and
        imp.ord_hdrnumber > 0  AND 
        NOT EXISTS
            (
                    SELECT 1 FROM paperwork lfa
                    WHERE   
                            lfa.abbr = 'LFA' AND
                            lfa.pw_imaged='Y' and
                            lfa.ord_hdrnumber = imp.ord_hdrnumber
            )

         
-- STEP 3:  Find all the orders that have a FTR but are missing an LFA.
--          Because some orders get scanned in with a '0' order header number
--          exclude these items with the ord_hrnumber >= 1 clause.
--          This step will probably put duplicate order header numbers into
--          the ord_temp table which will be dealth with further down.
         

INSERT  INTO #ord_tmp
SELECT  ord_hdrnumber
FROM    paperwork ftr
WHERE   ftr.abbr = 'FTR' AND
        ftr.pw_imaged='Y' and
        ftr.ord_hdrnumber >0 AND 
        NOT EXISTS
        (
            SELECT  1
            FROM    paperwork img
            WHERE                       
                    img.abbr = 'LFA' AND
                    img.pw_imaged='Y' and
                    img.ord_hdrnumber = ftr.ord_hdrnumber
        )


-- Step 4: initialize the aggregate data and set the default document flags       
--         The group-by clause here should eliminate the duplicate
--         ord_hdrnumbers that are in the #ord_temp table.

INSERT INTO #allorders
    (ord_hdrnumber, pw_ident,lfa_found, ftr_found)
SELECT  tmp.ord_hdrnumber, MAX(pw_ident), 'N','N'
FROM    #ord_tmp tmp inner join paperwork img 
                            on tmp.ord_hdrnumber = img.ord_hdrnumber
where
        img.pw_imaged='Y'
GROUP BY    tmp.ord_hdrnumber


-- Step 5: Purge any canceled orders from the list of prospective
--          orders missing a document.

DELETE      #allorders
FROM        #allorders img inner join  dbo.orderheader ord  
                on img.ord_hdrnumber = ord.ord_hdrnumber
WHERE       ord.ord_status = 'CAN'


-- Step 6: Update all items with a found flag for the LFA document
--         if any LFA document exists for that order number in the 
--         image import documents table.

UPDATE  #allorders
SET     lfa_found = 'Y'
FROM    #allorders tmp
WHERE EXISTS
        (
        SELECT  lfa.ord_hdrnumber
        FROM    paperwork lfa
        WHERE   lfa.ord_hdrnumber = tmp.ord_hdrnumber AND
                lfa.abbr = 'LFA' and
                lfa.pw_imaged='Y'
        )

-- STEP 7: update all items with a found flag for the FTR document
--         if any FTR exists for that order number in the image
--         import documents table.
        
UPDATE  #allorders
SET     ftr_found = 'Y'
FROM    #allorders tmp
WHERE EXISTS
        (
        SELECT  ord_hdrnumber
        FROM    paperwork ftr
        WHERE   ftr.ord_hdrnumber = tmp.ord_hdrnumber AND
                ftr.abbr = 'FTR' and
                ftr.pw_imaged='Y'
        )
        
-- STEP 8: This line will reduce the number of 'LFA, FTR required' messages
--         that are generated indicating that an FTR isn't requried for an
--         order whose load date is before the FTR_REQUIRED date.
--         pw_ident is used because it is the max(pw_ident) for an order which
--         will have the maximum load_date for that order.       

UPDATE  #allorders
SET     ftr_found = 'Y'
FROM    #allorders tmp inner join paperwork img on 
                        tmp.pw_ident = img.pw_ident
                       inner join orderheader on 
                       orderheader.ord_hdrnumber=img.ord_hdrnumber
WHERE   
        (
            orderheader.ord_origin_earliestdate <= @usa_date AND
            orderheader.ord_revtype1 like '%U'
        )
        OR
        (
            orderheader.ord_origin_earliestdate <= @cda_date AND
            orderheader.ord_revtype1 like '%C'
        )


-- Step 9: Delete the items from the temp table that have an LFA but no FTR
--         but whose load date is before the FTR_REQUIRED date.
--         It is possible to this point to have an item that has an LFA but
--         no FTR but a FTR wasn't required so a 'Y' 'Y' condition exists.

DELETE FROM #allorders 
WHERE   ftr_found = 'Y' AND  lfa_found = 'Y'


SELECT
  a.pw_ident,
  a.ord_hdrnumber,
  CASE
    WHEN lfa_found = 'N' AND ftr_found = 'N' THEN 'LFA, FTR Missing'
    WHEN lfa_found = 'N' THEN 'LFA Missing'
    WHEN ftr_found = 'N' THEN 'FTR Missing'
  END message,
  c.ord_billto,
  c.ord_revtype1,
  c.ord_shipper,
  c.ord_consignee,
  l.lgh_tractor,
  l.lgh_primary_trailer,
  l.lgh_driver1,
  origin.cty_nmstct,
  dest.cty_nmstct,
  c.cmd_code,
  c.ord_refnum,
  c.ord_origin_earliestdate,
  t.trc_terminal,
  a.abbr,
  a.last_updatedby,
  a.last_updateddatetime
FROM
  paperwork a inner join   #allorders b on a.pw_ident = b.pw_ident
              inner join   orderheader c on a.ord_hdrnumber=c.ord_hdrnumber
              inner join   legheader l on c.ord_hdrnumber=l.ord_hdrnumber
              inner join   tractorprofile t on l.lgh_tractor=t.trc_number
              inner join   company origin on c.ord_shipper=origin.cmp_id
              inner join   company dest on c.ord_consignee=dest.cmp_id
ORDER BY a.ord_hdrnumber

DROP TABLE #ord_tmp
DROP TABLE #allorders
GO
GRANT EXECUTE ON  [dbo].[d_imaging_missing_documents_sp] TO [public]
GO
