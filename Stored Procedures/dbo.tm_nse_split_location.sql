SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[tm_nse_split_location] @city varchar(50) AS
DECLARE @seqno INT

select @seqno=0, @city=ltrim(rtrim(@city))

IF @city IS NULL OR @city=''
	select @city='?'

IF ISNUMERIC(LEFT(@city,1))=1
BEGIN
	select @seqno=convert(int, LEFT(@city,1))
	select @city=ltrim(rtrim(substring(@city,2,99)))
END

select @seqno Column1, @city Column2

GO
GRANT EXECUTE ON  [dbo].[tm_nse_split_location] TO [public]
GO
