SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create proc [dbo].[ordrevtype1_fromdriver_sp] @mpp_id varchar(8), @mpp_type varchar(20), @ord_hdrnumber int 

as
declare	@mpp_type_value varchar(6)

SELECT @mpp_type_value = 
      	 CASE @mpp_type
	 	WHEN 'mpp_type1' THEN MPP_TYPE1
         	WHEN 'mpp_type2' THEN MPP_TYPE2
         	WHEN 'mpp_type3' THEN MPP_TYPE3
         	WHEN 'mpp_type4' THEN MPP_TYPE4
       	 ELSE ''
	 END
FROM MANPOWERPROFILE
WHERE MPP_ID = @MPP_ID 

IF @mpp_type_value <> '' and @mpp_type_value <> 'UNK'
	
	BEGIN
	
		UPDATE ORDERHEADER
		   SET ORD_REVTYPE1 = @MPP_TYPE_VALUE
		 WHERE ORD_HDRNUMBER =  @ord_hdrnumber 
	END

 IF @mpp_type_value = 'UNK' or @mpp_type_value = 'UNKNOWN'

	BEGIN
		
		UPDATE ORDERHEADER
		   SET ORD_REVTYPE1 = 'UNK'
		 WHERE ORD_HDRNUMBER = @ord_hdrnumber
	END

GO
GRANT EXECUTE ON  [dbo].[ordrevtype1_fromdriver_sp] TO [public]
GO
