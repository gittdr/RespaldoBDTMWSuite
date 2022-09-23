SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[validatemask] (
   @refnumber         VARCHAR(30),
   @mask              VARCHAR(30)
)
AS
DECLARE @reflength        INTEGER,
        @masklength       INTEGER,
        @a                INTEGER,
        @maskchar         CHAR(1),
        @refchar          CHAR(1),
        @alphas           VARCHAR(26),
        @numerics         VARCHAR(10)

SET @alphas = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
SET @numerics = '0123456789'

SET @reflength = Len(@refnumber)
SET @masklength = Len(@mask)

IF @reflength <> @masklength 
BEGIN
   RETURN -1
END

SET @a = 1
WHILE @a <= @masklength
BEGIN
   SET @maskchar = SUBSTRING(@mask, @a, 1)
   SET @refchar = SUBSTRING(@refnumber, @a, 1)

   IF @maskchar = '@'
   BEGIN
      IF CHARINDEX(@refchar, @alphas, 1) = 0
      BEGIN
         RETURN -1
      END
      ELSE
      BEGIN
         SET @a = @a + 1
         CONTINUE
      END
   END

   IF @maskchar = '#'
   BEGIN
      IF CHARINDEX(@refchar, @numerics, 1) = 0
      BEGIN
         RETURN -1
      END
      ELSE
      BEGIN
         SET @a = @a + 1
         CONTINUE
      END
   END

   IF @maskchar <> @refchar
   BEGIN
      RETURN -1
   END
   ELSE
   BEGIN
      SET @a = @a + 1
      CONTINUE
   END
END

RETURN 0


GO
GRANT EXECUTE ON  [dbo].[validatemask] TO [public]
GO
