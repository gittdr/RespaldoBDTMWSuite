SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[DuplicateCompanyCRMWorkAddress]  (@p_company_name varchar(100), @p_company_address varchar(255))					
AS
/**
 * 
 * NAME:
 * dbo.DuplicateCompanyCRMWorkAddress
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Provide a return set of all the apparent duplicate companycrmwork records 
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
@v_company_address varchar(100), 
@v_company_name varchar(100),
@v_company_address1 varchar(100),
@v_company_address2 varchar(100),
@v_company_address3 varchar(100),
@v_company_address4 varchar(100),
@v_company_address5 varchar(100),
--@TEST varchar(100),
--@TEST1 varchar(100),
--@TEST2 varchar(100),
@v_loc1      int,
@v_loc2      int,
@v_loc3      int,
@v_loc4      int,
@v_loc5	     int,
@v_space1    int,
@v_space2    int,
@v_len       int


CREATE TABLE #duplicate_company_address 
(company_id varchar(8)NULL,
 company_name varchar(100)NULL,
 company_address1 varchar(100)null, 
 company_address2 varchar(100)null,   	  
 cty_nmstct       varchar(25) null,
 company_zip      varchar(10)null,
 company_combo    varchar(255) null)

select @v_company_address1 = ''
select @v_company_address2 = ''
select @v_company_address3 = ''
select @v_company_address4 = ''

select @v_loc1 = charindex('+',RTRIM(@p_company_address))
select @v_loc2 = charindex('+',RTRIM(@p_company_address), @v_loc1 + 1)
select @v_loc3 = charindex('+',RTRIM(@p_company_address), @v_loc2 + 1)
select @v_loc4 = len(@p_company_address) - @v_loc3
--select @v_loc5 = len(@p_company_address) - @v_loc4

--print cast(@v_loc1 as varchar(20))
--print cast(@v_loc2 as varchar(20))
--print cast(@v_loc3 as varchar(20))
--print cast(@v_loc4 as varchar(20))
--print cast(@v_loc5 as varchar(20))

--cmp_address1
IF @v_loc1 > 0 
   BEGIN
        select @v_company_address1 = substring(@p_company_address,1,@v_loc1 -1) 
        select @v_space1 = charindex(' ',@v_company_address1)
        select @v_space2 = charindex(' ',@v_company_address1, @v_space1 + 1)
        
	IF @v_space2 > 0 
           BEGIN
             --print cast((@v_space2 -1) as varchar(20)) 
             --select @v_company_address1 = RTRIM(substring(@v_company_address1,1, @v_space2 -1))
 	     select @v_company_address1 = RTRIM(LTRIM(substring(@v_company_address1,1, @v_space2 -1)))	
           END
        ELSE
	   BEGIN
             select @v_len = len(RTRIM(@v_company_address1))
             --select @v_company_address1 = RTRIM(substring(@v_company_address1,1,@v_len ))
	     select @v_company_address1 = RTRIM(LTRIM(substring(@v_company_address1,1,@v_len )))
             --print cast(@v_len as varchar(20))  
	   END      
	--print @v_company_address1 
              
   END

--cmp_address2
IF @v_loc2 > 0
   BEGIN        
	--select @v_company_address2 = RTRIM(substring(@p_company_address, @v_loc1 + 1, (@v_loc2 - @v_loc1)- 1))
        select @v_company_address2 = RTRIM(LTRIM(substring(@p_company_address, @v_loc1 + 1, (@v_loc2 - @v_loc1)- 1)))
	--print @v_company_address2 
   END	

--cty_nmstct
IF @v_loc3 >0 
  BEGIN              
        --select @v_company_address3 = RTRIM(substring(@p_company_address,@v_loc2 + 1, (@v_loc3 - @v_loc2) - 1))
	select @v_loc5 = charindex('UNKNOWN',RTRIM(LTRIM(substring(@p_company_address,@v_loc2 + 1, (@v_loc3 - @v_loc2) - 1))))
        IF @v_loc5 > 0 
           BEGIN
               select @v_company_address3 = 'UNKNOWN'
           END 
        ELSE
	   BEGIN
		select @v_company_address3 = RTRIM(LTRIM(substring(@p_company_address,@v_loc2 + 1, (@v_loc3 - @v_loc2) - 1)))
           END
        --print @v_company_address3                          
  END

--cmp_zip
IF @v_loc4 >0
  BEGIN   
        --select @v_company_address4 = RTRIM(substring(@p_company_address,@v_loc3 + 1, @v_loc4))
        select @v_company_address4 = RTRIM(LTRIM(substring(@p_company_address,@v_loc3 + 1, @v_loc4)))                         
	--print @v_company_address4      
  END  

IF @v_company_address1 <> ''  AND @v_company_address4 <> ''
BEGIN
	INSERT INTO #duplicate_company_address
	SELECT cmp_id ,
	       cmp_name ,
	       cmp_address1,
	       cmp_address2,
	       cty_nmstct,
	       cmp_zip ,
	       isnull(LTRIM(RTRIM(cmp_address1)),'')+'+'+isnull(LTRIM(RTRIM(cmp_address2)),'')+'+'+LTRIM(RTRIM(cty_nmstct))+'+'+LTRIM(RTRIM(cmp_zip))          
	  FROM companycrmwork
	 WHERE --cmp_name like @p_company_name +'%'	
	       cmp_name like SUBSTRING(@p_company_name ,1,1) +'%'
	
	--PRINT @P_COMPANY_NAME         
	IF @v_space2 > 0
	   BEGIN
	       
	        IF @v_company_address3 <> 'UNKNOWN'
	         BEGIN
			--PRINT 'HI'
			SELECT company_id ,
			       company_name ,
			       company_address1,
			       company_address2,
			       cty_nmstct,
			       company_zip,
		               company_combo     
		          FROM #duplicate_company_address
		         WHERE PATINDEX('%'+@v_company_address1+'%',SUBSTRING(company_address1,1, @v_space2 -1)) > 0     		
		      	       AND PATINDEX('%'+@v_company_address3+'%',cty_nmstct) > 0
			       --SUBSTRING(company_address1,1, @v_space2 -1) LIKE @v_company_address1 + '%'	
		               AND PATINDEX('%'+@v_company_address4+'%',company_zip) > 0 
                         ORDER BY company_name ,cty_nmstct
	         END
	        ELSE
	         BEGIN   
			   --PRINT 'HELLO'
	                   --PRINT CAST(@v_space2 -1 AS VARCHAR(20))
	                   --PRINT @v_company_address1
			  SELECT company_id ,
			       company_name ,
			       company_address1,
			       company_address2,
			       cty_nmstct,
			       company_zip,
		               company_combo     
		          FROM #duplicate_company_address
		         WHERE PATINDEX('%'+@v_company_address1+'%',SUBSTRING(company_address1,1, @v_space2 -1)) > 0     		
			       --SUBSTRING(company_address1,1, @v_space2 -1) LIKE @v_company_address1 + '%'                            			      	       
		               AND PATINDEX('%'+@v_company_address4+'%',company_zip) > 0
                         ORDER BY company_name ,cty_nmstct		
	         END
	     END
	
	   ELSE
	     BEGIN
		  IF @v_company_address3 <> 'UNKNOWN'
			BEGIN
		          --print 'hey1'
		          --print @v_company_address1
		          --print cast(@v_loc3 + 4 as varchar(20))
		          --print cast(@v_loc4 as varchar(20))
			  --print cast(@v_len as varchar(20))
			  SELECT company_id ,
			       company_name ,
			       company_address1,
			       company_address2,
			       cty_nmstct,
			       company_zip,
		               company_combo     
		          FROM #duplicate_company_address
		         WHERE PATINDEX('%'+@v_company_address1+'%', SUBSTRING(company_address1,1,@v_len )) >0			
		      	       AND PATINDEX('%'+@v_company_address3+'%',cty_nmstct) > 0
			       AND PATINDEX('%'+@v_company_address4+'%',company_zip) > 0
	                       --SUBSTRING(company_address1,1,@v_len ) LIKE @v_company_address1 + '%' 
                         ORDER BY company_name ,cty_nmstct     		
			END
		  
		  ELSE 
			BEGIN
		          --print 'hey'
		          --print @v_company_address1
		          --print cast(@v_loc3 + 4 as varchar(20))
		          --print cast(@v_loc4 as varchar(20))
			  SELECT company_id ,
			       company_name ,
			       company_address1,
			       company_address2,
			       cty_nmstct,
			       company_zip,
		               company_combo     
		          FROM #duplicate_company_address
		         WHERE PATINDEX('%'+@v_company_address1+'%', SUBSTRING(company_address1,1,@v_len )) > 0     			      	       
			       --SUBSTRING(company_address1,1,@v_len ) LIKE @v_company_address1 + '%'      			      	       
			       AND PATINDEX('%'+@v_company_address4+'%',company_zip) > 0	
                         ORDER BY company_name ,cty_nmstct	
			END
	      END 
END

IF @v_company_address1 <> ''  AND @v_company_address4 = ''
BEGIN
	INSERT INTO #duplicate_company_address
	SELECT cmp_id ,
	       cmp_name ,
	       cmp_address1,
	       cmp_address2,
	       cty_nmstct,
	       cmp_zip ,
	       isnull(LTRIM(RTRIM(cmp_address1)),'')+'+'+isnull(LTRIM(RTRIM(cmp_address2)),'')+'+'+LTRIM(RTRIM(cty_nmstct))+'+'+LTRIM(RTRIM(cmp_zip))          
	  FROM companycrmwork
	 WHERE --cmp_name like @p_company_name +'%'	
	       cmp_name like SUBSTRING(@p_company_name ,1,1) +'%'
	
	--PRINT @P_COMPANY_NAME         
	IF @v_space2 > 0
	   BEGIN
	       
	        IF @v_company_address3 <> 'UNKNOWN'
	         BEGIN
			--PRINT 'HI'
			SELECT company_id ,
			       company_name ,
			       company_address1,
			       company_address2,
			       cty_nmstct,
			       company_zip,
		               company_combo     
		          FROM #duplicate_company_address
		         WHERE PATINDEX('%'+@v_company_address1+'%',SUBSTRING(company_address1,1, @v_space2 -1)) > 0     		
		      	       AND PATINDEX('%'+@v_company_address3+'%',cty_nmstct) > 0
			       --SUBSTRING(company_address1,1, @v_space2 -1) LIKE @v_company_address1 + '%'	
		               --AND PATINDEX('%'+@v_company_address4+'%',company_zip) > 0 
                         ORDER BY company_name ,cty_nmstct
	         END
	        ELSE
	         BEGIN   
			   --PRINT 'HELLO'
	                   --PRINT CAST(@v_space2 -1 AS VARCHAR(20))
	                   --PRINT @v_company_address1
			  SELECT company_id ,
			       company_name ,
			       company_address1,
			       company_address2,
			       cty_nmstct,
			       company_zip,
		               company_combo     
		          FROM #duplicate_company_address
		         WHERE PATINDEX('%'+@v_company_address1+'%',SUBSTRING(company_address1,1, @v_space2 -1)) > 0     		
			       --SUBSTRING(company_address1,1, @v_space2 -1) LIKE @v_company_address1 + '%'                            			      	       
		               --AND PATINDEX('%'+@v_company_address4+'%',company_zip) > 0
                         ORDER BY company_name ,cty_nmstct		
	         END
	     END
	
	   ELSE
	     BEGIN
		  IF @v_company_address3 <> 'UNKNOWN'
			BEGIN
		          --print 'hey1'
		          --print @v_company_address1
		          --print cast(@v_loc3 + 4 as varchar(20))
		          --print cast(@v_loc4 as varchar(20))
			  SELECT company_id ,
			       company_name ,
			       company_address1,
			       company_address2,
			       cty_nmstct,
			       company_zip,
		               company_combo     
		          FROM #duplicate_company_address
		         WHERE PATINDEX('%'+@v_company_address1+'%', SUBSTRING(company_address1,1,@v_len )) >0			
		      	       AND PATINDEX('%'+@v_company_address3+'%',cty_nmstct) > 0
			       --AND PATINDEX('%'+@v_company_address4,company_zip) > 0
	                       --SUBSTRING(company_address1,1,@v_len ) LIKE @v_company_address1 + '%' 
                         ORDER BY company_name ,cty_nmstct     		
			END
		  
		  ELSE 
			BEGIN
		          --print 'hey'
		          --print @v_company_address1
		          --print cast(@v_loc3 + 4 as varchar(20))
		          --print cast(@v_loc4 as varchar(20))
			  SELECT company_id ,
			       company_name ,
			       company_address1,
			       company_address2,
			       cty_nmstct,
			       company_zip,
		               company_combo     
		          FROM #duplicate_company_address
		         WHERE PATINDEX('%'+@v_company_address1+'%', SUBSTRING(company_address1,1,@v_len )) > 0     			      	       
			       --SUBSTRING(company_address1,1,@v_len ) LIKE @v_company_address1 + '%'      			      	       
			       --AND PATINDEX('%'+@v_company_address4+'%',company_zip) > 0	
                         ORDER BY company_name ,cty_nmstct	
			END
	      END 
END
GO
GRANT EXECUTE ON  [dbo].[DuplicateCompanyCRMWorkAddress] TO [public]
GO
