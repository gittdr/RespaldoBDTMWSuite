SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[edi_210_adjust_batch_number]

AS

declare @partnercount int, @nexttrpid varchar(35), @batchnbr int

SELECT @nexttrpid = ' '

Create table #EDI (
data_col varchar(200) null,
doc_id varchar(30) null,
trp_id varchar(20) null,
identity_col int null,
scac varchar(4) null) 

Insert Into #EDI (data_col, doc_id, trp_id, identity_col)
SELECT  data_col,
	doc_id,
	trp_id,
	identity_col
FROM	edi_210
WHERE   doc_ID in (SELECT doc_id from edi_210 where UPPER(SUBSTRING(data_col,1,3)) = 'END')
and     UPPER (SUBSTRING(data_col,1,3)) <> 'END'
ORDER BY trp_id,doc_id,identity_col

SELECT @partnercount = COUNT(DISTINCT(trp_id))
FROM 	#EDI

WHILE @partnercount > 0 
 BEGIN   
	SELECT @nexttrpid =  MIN(trp_id) 
	FROM #EDI
	WHERE trp_id > @nexttrpid

	IF ( SELECT COUNT(*) FROM edi_trading_partner WHERE trp_210id = @nexttrpid) > 0
		SELECT @batchnbr = max(ISNULL(trp_NxtCtlNbr,1))
		FROM   edi_trading_partner
		WHERE  trp_210id = @nexttrpid

		UPDATE edi_trading_partner
		SET    trp_NxtCtlNbr = (@batchnbr - 1)
		WHERE  trp_210id = @nexttrpid

   	SELECT @partnercount = @partnercount - 1

 END

GO
GRANT EXECUTE ON  [dbo].[edi_210_adjust_batch_number] TO [public]
GO
