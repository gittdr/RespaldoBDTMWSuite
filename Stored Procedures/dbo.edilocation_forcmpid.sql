SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[edilocation_forcmpid]
	@billtocmpid varchar( 8 )

 as
  SELECT @billtocmpid = ISNULL(@billtocmpid,'UNKNOWN')

  SELECT billto_cmp_id,
	cmp_id,
	ISNULL(ediloc_code,'') ediloc_code 
  FROM cmpcmp  WHERE billto_cmp_id = @billtocmpid
  order by billto_cmp_id, cmp_id





GO
GRANT EXECUTE ON  [dbo].[edilocation_forcmpid] TO [public]
GO
