SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  PROCEDURE [dbo].[tm_getallstoprefnums] @stp_number int = null

AS

DECLARE @ord_hdrnumber int,
	 @ref varchar(30),
	 @refs varchar(1000)

SELECT @refs = ''
SELECT @ord_hdrnumber=ord_hdrnumber FROM referencenumber WHERE ref_tablekey=@stp_number and ref_table='stops'
IF @@ROWCOUNT=0
	SELECT @ord_hdrnumber=ord_hdrnumber FROM STOPS WHERE stp_number=@stp_number 
print @ord_hdrnumber
IF ISNULL(@ord_hdrnumber,0)>0
BEGIN
	DECLARE ref_cur CURSOR FOR 
		SELECT isnull(ref_type,'')+' '+isnull(ref_number,'') ref 
		FROM referencenumber (NOLOCK)
		WHERE ref_table='stops' and ref_tablekey=@stp_number 
		UNION
		SELECT isnull(r.ref_type,'')+' '+isnull(r.ref_number,'') ref 
		FROM referencenumber r (NOLOCK), freightdetail f (NOLOCK)
		WHERE f.stp_number=@stp_number and r.ref_tablekey=f.fgt_number and r.ref_table='freightdetail'
		UNION
		SELECT isnull(ref_type,'')+' '+isnull(ref_number,'') ref 
		FROM referencenumber (NOLOCK)
		WHERE ref_table='orderheader' and ref_tablekey=@ord_hdrnumber
		UNION
		SELECT isnull(ref_type,'')+' '+isnull(ref_number,'') ref 
		FROM referencenumber (NOLOCK)
		WHERE ref_table='freightdetail' and ord_hdrnumber=@ord_hdrnumber
		UNION
		SELECT isnull(ref_type,'')+' '+isnull(ref_number,'') ref 
		FROM referencenumber (NOLOCK)
		WHERE ref_table='stops' and ord_hdrnumber=@ord_hdrnumber
	
		OPEN ref_cur
			FETCH NEXT FROM ref_cur INTO @ref
			WHILE @@fetch_status = 0
			BEGIN
				SELECT @refs = @refs + ',' + @ref
				FETCH NEXT FROM ref_cur INTO @ref 
			END
		CLOSE ref_cur
	DEALLOCATE ref_cur
END 
SELECT SUBSTRING(@refs + ' ',2,999) ref

GO
GRANT EXECUTE ON  [dbo].[tm_getallstoprefnums] TO [public]
GO
