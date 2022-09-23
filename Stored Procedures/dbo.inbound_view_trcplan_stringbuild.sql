SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[inbound_view_trcplan_stringbuild] (@lgh INT, @detail INT, @string VARCHAR(255) OUTPUT)
AS

DECLARE @SQLstring nvarchar(4000), 
        @cols INT, 
        @col  VARCHAR(100), 
        @start INT, 
        @length INT, 
        @tmpstring NVARCHAR(255), 
        @displaylabel INT, 
        @label VARCHAR(100), 
        @stop INT, 
        @mfh  INT

CREATE TABLE #jtmp 
       (stringvalue VARCHAR(255))


IF @detail = 0
BEGIN
   SET @SQLString = N'INSERT INTO #jtmp (stringvalue) SELECT CONVERT(VARCHAR(11), lgh_number) + '': '
   
   SELECT @mfh = MIN(stp_mfh_sequence) 
     FROM stops 
    WHERE lgh_number = @lgh
   WHILE @mfh > 0
   BEGIN
        SELECT @stop = MIN(stp_number) 
          FROM stops 
         WHERE lgh_number = @lgh AND 
               stp_mfh_sequence = @mfh
        	
	SELECT @cols = MIN(sortorder) 
	  FROM tractorplanlayout 
	 WHERE detail = @detail
	WHILE @cols > 0 
	BEGIN 
	     SELECT @col = field, @start = startingposition, @length = numbercharacters, 
	            @displaylabel = displaylabel, @label = label 
	       FROM tractorplanlayout 
	      WHERE detail = @detail AND 
	            sortorder = @cols
             
	     IF @displaylabel = 1
	        SELECT @SQLString = @SQLString + N''' + ''' + @label + N': ' 
	     
	     SELECT @SQLString = @SQLString + N''' + SUBSTRING(CONVERT(VARCHAR(255), ' + @col + '), ' + 
	                         CONVERT(VARCHAR(6), @start) + ', ' + CONVERT(VARCHAR(6), @length) + ') + '' '
	     
	     SELECT @cols = MIN(sortorder) 
	       FROM tractorplanlayout 
	      WHERE detail = @detail AND 
	            sortorder > @cols
	END
	SELECT @SQLString = @SQLString + N''' FROM stops WHERE stp_number = ' + CONVERT(VARCHAR(10), @stop)
        EXEC sp_executesql @SQLString
        
        SELECT @tmpstring = stringvalue 
          FROM #jtmp 
        
        SET @string = @string + ' ' + @tmpstring
        
        DELETE FROM #jtmp
        
        SELECT @mfh = MIN(stp_mfh_sequence) 
          FROM stops 
         WHERE lgh_number = @lgh AND 
               stp_mfh_sequence > @mfh
        SET @SQLString = N'INSERT INTO #jtmp (stringvalue) SELECT '' '
   END
END  
ELSE
BEGIN
   SET @SQLString = N'INSERT INTO #jtmp (stringvalue) SELECT CONVERT(VARCHAR(11), lgh_number) + '': '

   SELECT @cols = MIN(sortorder) 
     FROM tractorplanlayout 
    WHERE detail = @detail
   WHILE @cols > 0 
   BEGIN 
        SELECT @col = field, @start = startingposition, @length = numbercharacters, 
               @displaylabel = displaylabel, @label = label 
          FROM tractorplanlayout 
         WHERE detail = @detail AND 
               sortorder = @cols

        IF @displaylabel = 1
           SELECT @SQLString = @SQLString + N''' + ''' + @label + N': ' 
        
        SELECT @SQLString = @SQLString + N''' + SUBSTRING(CONVERT(VARCHAR(255), ' + @col + '), ' + 
                         CONVERT(VARCHAR(6), @start) + ', ' + CONVERT(VARCHAR(6), @length) + ') + '' '
        
        SELECT @cols = MIN(sortorder) 
          FROM tractorplanlayout 
         WHERE detail = @detail AND 
               sortorder > @cols
  END
  SELECT @SQLString = @SQLString + N''' FROM legheader WHERE lgh_number = ' + CONVERT(VARCHAR(10), @lgh)
  
  EXEC sp_executesql @SQLString
  
  SELECT @string = stringvalue 
    FROM #jtmp 
END  

DROP TABLE #jtmp
GO
GRANT EXECUTE ON  [dbo].[inbound_view_trcplan_stringbuild] TO [public]
GO
