SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_refs_at_stop]		 @StopNumber varchar(20),
		 		 		 		 		 @RefNumType varchar(6)
AS

SET NOCOUNT ON 

declare @intStop int
IF isnumeric(@StopNumber) <> 0
	BEGIN
	SELECT @intStop = CONVERT(int, @StopNumber)
		 IF isnull(@RefNumType, '')  = ''
		 		 SELECT *
		 		 FROM referencenumber (NOLOCK)
		 		 left join freightdetail (NOLOCK) ON ref_tablekey = fgt_number 
				 where (ref_table = 'stops' and ref_tablekey = @intStop)
		 		 UNION
				 SELECT *
				 FROM referencenumber (NOLOCK)
				 left join freightdetail (NOLOCK) ON ref_tablekey = fgt_number 
				 where  (ref_table = 'freightdetail' and ref_tablekey in
					(select fgt_number 
						FROM freightdetail (NOLOCK)
						where stp_number = @intStop))
		 		 ORDER BY ref_number, ref_type
		 ELSE
		 		 SELECT * 
		 		 FROM referencenumber (NOLOCK)
		 		 left join freightdetail (NOLOCK) ON ref_tablekey = fgt_number 
		 		 WHERE (ref_table = 'stops' and ref_tablekey = @intStop)
		 		 	 and ref_type = @RefNumType
		 		 UNION
				 SELECT *
				 FROM referencenumber (NOLOCK)
				 left join freightdetail (NOLOCK) ON ref_tablekey = fgt_number 
				 where (ref_table = 'freightdetail' and ref_tablekey in
					(select fgt_number 
						FROM freightdetail (NOLOCK)
						WHERE stp_number = @intStop)) and ref_type = @RefNumType
		 		 ORDER BY ref_number, ref_type
	END
ELSE
		 SELECT * 
		 FROM referencenumber (NOLOCK)
		 WHERE 1=2
GO
GRANT EXECUTE ON  [dbo].[tmail_refs_at_stop] TO [public]
GO
