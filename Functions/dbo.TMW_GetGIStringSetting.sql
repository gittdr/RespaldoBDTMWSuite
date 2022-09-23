SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[TMW_GetGIStringSetting]
  (@p_GIName varchar(100),@p_GIStringNumber char(1)) 
RETURNS varchar(100)
AS
/*
 * NAME:
 * dbo.TMW_GetGIString1Setting
 *
 * TYPE:
 * function
 *
 * DESCRIPTION:
 * Returns the string1 value for a GI setting, tries to return defaul value if null
 * Arguments
 *  the gi name value for the setting ot be returned
 *  the number '1','2','3','4' of the string value
 * RETURNS:
 * varchar(100)  gi_string1
 *
 * RESULT SETS: 
 * 
 *
 * PARAMETERS:
 * 001 - @p_GIName the gi_name velu for the generalinfo table
 * 
 * REVISION HISTORY:
 * 5/10/10 DPETE created for dot net

 *
 * Sample call
    declare @x varchar(100)
    exec @x = TMW_GetGIString1Setting ('PaperWorkMode','1')
    select @x
 */   
  
BEGIN
   DECLARE @v_GIString varchar(100)
 
   Select @v_GIString = 
     Case @p_GIStringNumber
     when '1' then isnull(rtrim(gi_string1),'')
     when '2' then isnull(rtrim(gi_string2),'')
     when '3' then isnull(rtrim(gi_string3),'')
     when '4' then isnull(rtrim(gi_string4),'')
     else ''
     end
  From generalinfo where gi_name = @p_GIName

/* enter defaults for string 1 value here */
  If @v_GIString is null and @p_GIStringNumber = '1'
    select @v_GIString =
      Case @v_GIString
        when 'DefaultCompanyPaperwork' then 'N'
        when 'PaperworkCheckLevel' then 'ORD'  --PTS16282 / 43837 
        when 'PaperworkCutoffDate' then  'N' -- PTS45550 need gi int values if Y
        when 'PaperworkMarkedYes' then 'ALL'  --PTS 12470/52051 when ONE only need one doc received
        when 'PaperworkMode' then 'A'
        when 'PaperworkOverrideExceptionType' then  'N' --PTS32780 (requires string1,2,3)
        --when 'RequirePaperworkToSettle' then 'N'  -- 16982 ini
        when 'SetInvoiceBillDateOnRelease' then 'N'  --PTS32222
        else ''
        end

  
   RETURN @v_GIString
END
GO
GRANT EXECUTE ON  [dbo].[TMW_GetGIStringSetting] TO [public]
GO
