SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.getsystemedinumber    Script Date: 6/1/99 11:54:04 AM ******/
create procedure [dbo].[getsystemedinumber] @edicat varchar(20), @systemnumber int output
AS

exec @systemnumber = getsystemnumber @edicat, ""


GO
GRANT EXECUTE ON  [dbo].[getsystemedinumber] TO [public]
GO
