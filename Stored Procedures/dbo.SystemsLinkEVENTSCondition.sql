SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[SystemsLinkEVENTSCondition] 
(
@Collection VARCHAR(MAX),
@ORD_HDRNUMBER int,
@WORKFLOWTEMPLATEID int,
@Type varchar(50),
@ReturnVal varchar(max) output
)

AS

BEGIN
DECLARE @Column varchar(30), @Column_End int,@ResultVar varchar(max), @InsrtSqlcmd varchar(MAX) 


 SET @ReturnVal = 'SELECT COUNT(0) FROM EVENT E JOIN STOPS S ON S.STP_NUMBER = E.STP_NUMBER RIGHT JOIN SLWCEVENTTRACKING_'+CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)+' ET ON ET.STP_NUMBER = E.STP_NUMBER 
			WHERE ET.STP_TYPE IN ('+@Type+') AND ET.STP_NUMBER = E.STP_NUMBER AND e.evt_number = et.evt_number and E.ORD_HDRNUMBER =' +CONVERT(VARCHAR(50),@ORD_HDRNUMBER)  
			WHILE LEN(@Collection) > 0
				BEGIN --WHILE
				SET @Column_End = CHARINDEX(',', @Collection)
				IF @Column_End = 0
				SET @Column_End = LEN(@Collection) + 1
				SET @Column = LTRIM(RTRIM(LEFT(@Collection, @Column_End - 1)))
				SET @ReturnVal = @ReturnVal  + ' AND ISNULL(E.[' + @Column + '],0)  =  ISNULL(ET.[' + @Column + ']'+',0)'
				SET @Collection = SUBSTRING(@Collection, @Column_End + 1, 2000000000)
				SET @InsrtSqlcmd = 'INSERT INTO orderdatatracking (ord_hdrnumber, mov_number, lgh_number, odt_tablekey, odt_tablename ,odt_message,odt_columnname, odt_oldvalue, odt_newvalue, odt_createddate, odt_updateddate, odt_reviewed) SELECT '+ 
				CONVERT(VARCHAR(50),@Ord_hdrnumber)+', s.mov_number , s.lgh_number, e.evt_number,''event'', ''Eventchanged'','''+ @Column + ''', ET.['+CONVERT(VARCHAR(50),@Column)+'], E.['+CONVERT(VARCHAR(50),@Column)+'],GETDATE(),GETDATE(),0 FROM STOPS S, EVENT E, SLWCEVENTTRACKING_'+
				CONVERT(VARCHAR(50),@WORKFLOWTEMPLATEID)+' ET WHERE S.STP_NUMBER = E.STP_NUMBER AND ET.STP_NUMBER = E.STP_NUMBER AND e.ord_hdrnumber=s.ord_hdrnumber AND e.evt_number = et.evt_number  AND E.ORD_HDRNUMBER = '+CONVERT(VARCHAR(50),@Ord_hdrnumber)+
				'  AND ISNULL(E.[' + @Column + '],0) !=  ISNULL(ET.[' + @Column + '],0)'
				EXEC(@InsrtSqlcmd)
				END --WHILE
			--INSERT @TempTable
	
END

GO
GRANT EXECUTE ON  [dbo].[SystemsLinkEVENTSCondition] TO [public]
GO
