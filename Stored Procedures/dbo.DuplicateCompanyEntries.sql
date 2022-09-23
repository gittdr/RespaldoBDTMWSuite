SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[DuplicateCompanyEntries]  (@p_company_name varchar(100), @p_company_address1 varchar(100))					
AS
/**
 * 
 * NAME:
 * dbo.DuplicateCompanyEntries
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Provide a return set of all the apparent duplicate company records 
 * based on the company id selected in the company profile interfeace. 
 *
 * RETURNS:
 * N/A
 *
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS:
 * 001 - @p_company_id, , varchar(8),input, null;
 * 002 - @P_company_address1, varchar(100), input, null;      
 *
 * REFERENCES: (called by and calling references only, don't 
 *              include table/view/object references)
 **/

DECLARE 
@v_company_name varchar(100), 
@v_company_address1 varchar(100),
@v_company_name1 varchar(100),
@v_company_name2 varchar(100),
@v_company_name3 varchar(100),
--@TEST varchar(100),
--@TEST1 varchar(100),
--@TEST2 varchar(100),
@v_loc1      int,
@v_loc2      int,
@v_loc3      int

CREATE TABLE #duplicate_company_names 
(company_id varchar(8)NULL,
 company_name varchar(100)NULL,
 company_address1 varchar(100)null,
 cty_nmstct       varchar(25) null) 

select @v_company_name1 = ''
select @v_company_name2 = ''
select @v_company_name3 = ''

select @v_loc1 = charindex(' ',RTRIM(@p_company_name))
select @v_loc2 = charindex(' ',RTRIM(@p_company_name), @v_loc1 + 1)
select @v_loc3 = len(RTRIM(@p_company_name)) - @v_loc2

--print cast(@v_loc1 as varchar(20))
--print cast(@v_loc2 as varchar(20))
--print cast(@v_loc3 as varchar(20))

IF @v_loc1 > 0 
   BEGIN
	select @v_company_name1 = substring(@p_company_name,1,@v_loc1 -1)        
	--print @v_company_name1
   END
ELSE
   BEGIN        
	select @v_company_name1 = @p_company_name
   END

IF @v_loc2 > 0
   BEGIN
	select @v_company_name2 = substring(@p_company_name, @v_loc1 + 1, (@v_loc2 - @v_loc1)- 1)
	--print @v_company_name2
 
	select @v_company_name3 = substring(@p_company_name,@v_loc2 + 1, @v_loc3)                         
	--print @v_company_name3      
  END
ELSE
  BEGIN   
        IF @v_loc1 > 0 
           BEGIN     
		select @v_company_name2 = substring(@p_company_name, @v_loc1 + 1, (@v_loc3 - @v_loc1))      	
         	--print @v_string2
	   END
  END

INSERT INTO #duplicate_company_names
SELECT cmp_id ,
       cmp_name ,
       cmp_address1,
       cty_nmstct    
  FROM company
 WHERE cmp_name like @v_company_name1 +'%'

IF @v_company_name1 <> '' and @v_company_name2 = '' 
    BEGIN
	--print '1'
	SELECT company_id,
      	       company_name,
               company_address1 
          FROM #duplicate_company_names      
      ORDER BY company_name ,cty_nmstct ASC 
    END
  
IF @v_company_name1 <> '' and @v_company_name2 <> '' and @v_company_name3 = ''
   BEGIN
        --print '2'	
        IF @v_loc2 > 0
             BEGIN
		SELECT company_id ,
	      	       company_name ,
	               company_address1    
	          FROM #duplicate_company_names
	         WHERE SUBSTRING(company_name,@v_loc1 + 1,(@v_loc2 - @v_loc1)- 1) like @v_company_name2 +'%'
		 ORDER BY company_name ,cty_nmstct ASC 
             END
        ELSE
	     BEGIN
		SELECT company_id ,
	      	       company_name ,
	               company_address1    
	          FROM #duplicate_company_names
	         WHERE SUBSTRING(company_name, @v_loc1 + 1,(@v_loc3 - @v_loc1)) like @v_company_name2 +'%'
                 ORDER BY company_name ,cty_nmstct ASC 
             END 
   END

IF @v_company_name1 <> '' and @v_company_name2 <> '' and @v_company_name3 <> '' and @v_loc3 <> 0
   BEGIN
	--print '3'        
	SELECT company_id ,
      	       company_name ,
               company_address1    
          FROM #duplicate_company_names
         WHERE SUBSTRING(company_name,@v_loc1 + 1,(@v_loc2 - @v_loc1)- 1) like @v_company_name2 +'%'
           AND SUBSTRING(company_name,@v_loc2 + 1, @v_loc3) LIKE @v_company_name3 +'%'
          ORDER BY company_name ,cty_nmstct ASC 
    END  
GO
GRANT EXECUTE ON  [dbo].[DuplicateCompanyEntries] TO [public]
GO
