SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[GET_CUR_TIMESTAMP_CHAR] ( @CURRENTDBTS [VARCHAR](1000) OUTPUT )
AS
BEGIN
DECLARE @ts TIMESTAMP
DECLARE @TSB BINARY(64)

SELECT @ts = @@DBTS -- current timestamp
SELECT @TSB = CONVERT(VARBINARY(64),@ts,2)

SELECT @CURRENTDBTS = '0x'+ CONVERT(varchar(16),@TSB,2)
END
GO