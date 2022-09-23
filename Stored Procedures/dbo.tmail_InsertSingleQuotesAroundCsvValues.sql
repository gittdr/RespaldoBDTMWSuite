SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_InsertSingleQuotesAroundCsvValues]  
(   
 @csvString varchar(60),  
 @separator varchar(5),  
 @output NVARCHAR(200) OUT  
)  
AS  
  
/**  
 *   
 * NAME:  
 * dbo.[tmail_InsertSingleQuotesAroundCsvValues]  
 *  
 * TYPE:  
 * Stored Procedure  
 *  
 * DESCRIPTION:  
 * take value [@csvString], remove all single quotes, remove all spaces  
 * add single quotes around each string segment separated by [@separator]  
 * final value set to @output  
 *   
 * example 1:  @csvString = LLD, HPL, HLT  
 *      @separator = ,  
 * return value: 'LLD','HPL','HLT'  
 *   
 * example 2:  @csvString = LLD-HPL-HLT  
 *      @separator = -  
 * return value: 'LLD'-'HPL'-'HLT'  
 *   
 * RETURNS:  
 *  varchar(200)  
 *   
 * PARAMETERS:  
 * 001 - @csvString : varchar(60) containing two or more values separated by a separator value  
 * 002 - @separator : varchar(5) containing separator value  
 * 003 - @output : varchar(200) set to output value  
 *   
 * REVISION HISTORY:  
 * 07/29/2014.01 - PTS80063 - APC - created proc  
 * 08/20/2014.01 - PTS80063 - APC - delete proc if it already exists before creating it
 *  
 **/  
  
SET NOCOUNT ON  
  
-- remove all single quotes  
SET @csvString = REPLACE(@csvString, '''', '')  
  
-- remove all spaces  
SET @csvString = REPLACE(@csvString, ' ', '')  
  
-- replace separator(i.e. comma) with same separator surrounded by single quotes  
SET @output = REPLACE(@csvString, @separator, '''' + @separator + '''')  
  
-- append single quote to front and end of string  
SET @output = '''' + @output + ''''  

GO
GRANT EXECUTE ON  [dbo].[tmail_InsertSingleQuotesAroundCsvValues] TO [public]
GO
