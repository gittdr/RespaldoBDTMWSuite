SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.make_ordnum    Script Date: 6/1/99 11:54:04 AM ******/
create PROCEDURE [dbo].[make_ordnum]
	@ord int,
	@ordnum char ( 12 ) OUT

AS

SELECT @ordnum = CONVERT ( char ( 12 ), @ord )





GO
GRANT EXECUTE ON  [dbo].[make_ordnum] TO [public]
GO
