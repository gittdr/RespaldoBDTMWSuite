SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SystemsLinkProcessing]
    @Test1             nvarchar(256),
    @Test2             nvarchar(256),
    @DateTime     DateTime,
    @Float      Float(5),
    @Bit      Bit
    
AS
BEGIN
SELECT @Test1 as FirstName, 
  @Test2 As LastName, 
  @Test1 + ' : ' + @Test2 As FullName,
  @DateTime + 3 As Plus3Days,
  @Float + 1 as FloatPlusOne,
  @Bit As TheBit
END
GO
GRANT EXECUTE ON  [dbo].[sp_SystemsLinkProcessing] TO [public]
GO
