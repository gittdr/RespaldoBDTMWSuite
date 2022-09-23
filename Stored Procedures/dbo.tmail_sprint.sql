SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/**
 *
 * NAME:
 * dbo.tmail_sprint
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure replaces placeholders @Replacement1-10 in @MasterString
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
 *
 * REFERENCES: 
 * n/a
 *
 * REVISION HISTORY:
 * 11/02/2009.01 – PTSxxxxx - LB – Copied tm version to tmail version
 *
 **/

CREATE PROCEDURE [dbo].[tmail_sprint]
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
	@Replacement10 varchar(255)
AS

SET NOCOUNT ON

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
GRANT EXECUTE ON  [dbo].[tmail_sprint] TO [public]
GO
