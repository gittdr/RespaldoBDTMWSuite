SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[SearchAPI_CheckCalls] @KEYWORDSEARCH  VARCHAR(250),
                                        @ADVANCEDSEARCH VARCHAR(MAX),
                                        @PAGESIZE       INT,
                                        @PAGEINDEX      INT
AS

/*******************************************************************************************************************  
  Object Description:
  This stored proc provides search capabilities for a keyword search and an advanced search

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  02/27/2017   Chip Ciminero    WE-?????   Created
  10/09/2017   Chase Plante     WE-211090   Modified proc to trim any string data
*******************************************************************************************************************/

     --SP PARAMS / TEST DATA
     --IF YOU SEARCH FOR A KEYWORD, IT WILL IGNORE ADVANCED SEARCH
     --ADDING MULTIPLE CRITERIA IN ADVANCED SEARCH WILL REQUIRE ALL FIELDS ENTERED TO BE SATISFIED
     --DECLARE @KEYWORDSEARCH VARCHAR(250), @ADVANCEDSEARCH VARCHAR(MAX), @PAGESIZE INT, @PAGEINDEX INT
     --SELECT @KEYWORDSEARCH = '613'
     --, @ADVANCEDSEARCH=''
     --, @PAGESIZE = 20, @PAGEINDEX = 1

     DECLARE @ADV_SRCH_PARAMS TABLE (PropertyName  VARCHAR(250), PropertyValue VARCHAR(250));

     IF LEN(@ADVANCEDSEARCH) > 0
         BEGIN
             INSERT INTO @ADV_SRCH_PARAMS
                    SELECT NAME,
                           STRINGVALUE
                    FROM parseJSON(@ADVANCEDSEARCH);
         END;
     --SELECT * FROM @ADV_SRCH_PARAMS

     WITH Data(CheckCallNumber,
               LegHeaderNumber,
               EventCode,
               AsgnType,
               AsgnId,
               TractorNumber,
               DateOfCall,
               City,
               CityName,
               State,
               Zip,
               RawLatSeconds,
               RawLongSeconds,
               Status,
               Comment,
               RowNum)
          AS (SELECT C.ckc_number 'CheckCallNumber',
                     C.ckc_lghnumber 'LegHeaderNumber',
                     C.ckc_event 'EventCode',
                     C.ckc_asgntype 'AsgnType',
                     LTRIM(RTRIM(C.ckc_asgnid)) 'AsgnId',
                     LTRIM(COALESCE(C.ckc_tractor, '')) 'TractorNumber',
                     C.ckc_date 'DateOfCall',
                     C.ckc_city 'City',
                     LTRIM(RTRIM(COALESCE(C.ckc_cityname, ''))) 'CityName',
                     LTRIM(RTRIM(COALESCE(C.ckc_state, ''))) 'State',
                     LTRIM(RTRIM(COALESCE(C.ckc_zip, ''))) 'Zip',
                     C.ckc_latseconds 'RawLatSeconds',
                     C.ckc_longseconds 'RawLongSeconds',
                     LTRIM(C.ckc_status) 'Status',
                     LTRIM(COALESCE(C.ckc_comment, '')) 'Comment',
                     ROW_NUMBER() OVER(ORDER BY C.ckc_date DESC) AS RowNum
              FROM checkcall C
              WHERE C.ckc_lghnumber = @KEYWORDSEARCH)
          SELECT *
          FROM Data
          WHERE RowNum > @PAGESIZE * (@PAGEINDEX - 1)
                AND RowNum <= @PAGESIZE * @PAGEINDEX
          ORDER BY RowNum;
GO
GRANT EXECUTE ON  [dbo].[SearchAPI_CheckCalls] TO [public]
GO
