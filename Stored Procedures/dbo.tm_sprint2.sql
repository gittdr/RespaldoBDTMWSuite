SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/**
 *
 * NAME:
 * dbo.tm_sprint2
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure replaces placeholders @Replacement1-20 in @MasterString
 *
 * RETURNS:
 * @MasterString with placeholders replaced with correct values
 *
 * RESULT SETS:
 * n/a
 *
 * PARAMETERS:
 * 001 - @MasterString varchar(1500)
 * 002 - @Replacement1 varchar(255)
 * 003 - @Replacement2 varchar(255)
 * 004 - @Replacement3 varchar(255)
 * 005 - @Replacement4 varchar(255)
 * 006 - @Replacement5 varchar(255)
 * 007 - @Replacement6 varchar(255)
 * 008 - @Replacement7 varchar(255)
 * 009 - @Replacement8 varchar(255)
 * 010 - @Replacement9 varchar(255)
 * 011 - @Replacement10 varchar(255)
 * 012 - @Replacement11 varchar(255)
 * 013 - @Replacement12 varchar(255)
 * 014 - @Replacement13 varchar(255)
 * 015 - @Replacement14 varchar(255)
 * 016 - @Replacement15 varchar(255)
 * 017 - @Replacement16 varchar(255)
 * 018 - @Replacement17 varchar(255)
 * 019 - @Replacement18 varchar(255)
 * 020 - @Replacement19 varchar(255)
 * 021 - @Replacement20 varchar(255)
 *
 * REFERENCES: 
 * n/a
 *
 * REVISION HISTORY:
 * 05/10/2010.01 – PTS37001 - LB – New version with parameters up to 20
 *
 **/

CREATE PROCEDURE [dbo].[tm_sprint2]
	@MasterString varchar(1500) out,
	@Replacement1 varchar(255),
	@Replacement2 varchar(255),
	@Replacement3 varchar(255),
	@Replacement4 varchar(255),
	@Replacement5 varchar(255),
	@Replacement6 varchar(255),
	@Replacement7 varchar(255),
	@Replacement8 varchar(255),
	@Replacement9 varchar(255),
	@Replacement10 varchar(255),
	@Replacement11 varchar(255),
	@Replacement12 varchar(255),
	@Replacement13 varchar(255),
	@Replacement14 varchar(255),
	@Replacement15 varchar(255),
	@Replacement16 varchar(255),
	@Replacement17 varchar(255),
	@Replacement18 varchar(255),
	@Replacement19 varchar(255),
	@Replacement20 varchar(255)
AS

SET NOCOUNT ON
SELECT @MasterString = REPLACE( @MasterString, '~20', ISNULL(@Replacement20, '(null)') )
SELECT @MasterString = REPLACE( @MasterString, '~19', ISNULL(@Replacement19, '(null)') )
SELECT @MasterString = REPLACE( @MasterString, '~18', ISNULL(@Replacement18, '(null)') )
SELECT @MasterString = REPLACE( @MasterString, '~17', ISNULL(@Replacement17, '(null)') )
SELECT @MasterString = REPLACE( @MasterString, '~16', ISNULL(@Replacement16, '(null)') )
SELECT @MasterString = REPLACE( @MasterString, '~15', ISNULL(@Replacement15, '(null)') )
SELECT @MasterString = REPLACE( @MasterString, '~14', ISNULL(@Replacement14, '(null)') )
SELECT @MasterString = REPLACE( @MasterString, '~13', ISNULL(@Replacement13, '(null)') )
SELECT @MasterString = REPLACE( @MasterString, '~12', ISNULL(@Replacement12, '(null)') )
SELECT @MasterString = REPLACE( @MasterString, '~11', ISNULL(@Replacement11, '(null)') )
SELECT @MasterString = REPLACE( @MasterString, '~10', ISNULL(@Replacement10, '(null)') )
SELECT @MasterString = REPLACE( @MasterString, '~9', ISNULL(@Replacement9, '(null)') )
SELECT @MasterString = REPLACE( @MasterString, '~8', ISNULL(@Replacement8, '(null)') )
SELECT @MasterString = REPLACE( @MasterString, '~7', ISNULL(@Replacement7, '(null)') )
SELECT @MasterString = REPLACE( @MasterString, '~6', ISNULL(@Replacement6, '(null)') )
SELECT @MasterString = REPLACE( @MasterString, '~5', ISNULL(@Replacement5, '(null)') )
SELECT @MasterString = REPLACE( @MasterString, '~4', ISNULL(@Replacement4, '(null)') )
SELECT @MasterString = REPLACE( @MasterString, '~3', ISNULL(@Replacement3, '(null)') )
SELECT @MasterString = REPLACE( @MasterString, '~2', ISNULL(@Replacement2, '(null)') )
SELECT @MasterString = REPLACE( @MasterString, '~1', ISNULL(@Replacement1, '(null)') )
GO
GRANT EXECUTE ON  [dbo].[tm_sprint2] TO [public]
GO
