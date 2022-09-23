SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[tmw_AddLabelFileEntries_sp]
@error INT OUTPUT
,@mode VARCHAR(10)
,@labeldefinition VARCHAR(20)
,@abbr VARCHAR(6)
,@name VARCHAR(20)
,@userlabelname VARCHAR(20)
AS /**
*
* NAME:
* dbo.tmw_AddLabelFileEntries_sp
*
* TYPE:
* Stored Procedure
*
* DESCRIPTION:
* This procedure will allow the addition of labelfile entries for pre-existing label definitions.  This will not add new labeldefinitions
*
* RETURNS:
*
*
* RESULT SETS:
*
*
* PARAMETERS:
* 001 - @error   Error code output
*       0 Vaild existing entry
*       1 Succesfully insertion of new entry
*      -1 couldn't get valid code
*      -2 could not insert a new labelfile entry becuase the labledefinition did not exist
*		-3 Label entry is invlaid.
* 002 - @mode How to handle the call
*       ADD indicates insertion of new record if not found
*       VALIDATE  indicates just validation
*
*
* 003 - @labeldefinition
*       labeldefinition on the labelfile table
* 004 - @abbr
*       Abbr on the labelfile table
* 005 - @name
*       Name on the labelfile table
* 006 - @userlabelname
*       UserLabelname on the labelfile table
* REFERENCES:
*
* Calls001 -
*			declare @error int
*           exec tmw_AddLabelFileEntries_sp @error out, 'ADD', '1099types', 'Test', 'Class', '1099types'
* This will add a new 1099type of test (if you do this you shoudld delete it)  and return a 1  run it a second time and it should return 0
*
* Calls002 -
*           declare @error int
*           exec tmw_AddLabelFileEntries_sp @error out, 'ADD', 'TEST', 'TEST', 'TEST', 'TEST'
* This will add a Attemp to add a new TEST labelfile and Fail because there is no TEST labeldefinition it should return -1
*
* CalledBy001 -
* CalledBy002 -
*
* REVISION HISTORY:
* 10/10/2012.01 PTS65294 - ksmader -creation
*
**/

BEGIN

IF ISNULL(@name, '') = ''
SET @name = @labeldefinition
IF ISNULL(@userlabelname, '') = ''
SET @userlabelname = @labeldefinition

IF ISNULL(@abbr, '') = ''
BEGIN
SET @error = -3
RETURN
END

DECLARE @code INT
,@count INT

SELECT @count = COUNT(*)
FROM   labelfile
WHERE  labeldefinition = @labeldefinition
AND abbr = @abbr
IF @count > 0
BEGIN
SET @error = 0
-- Confirmed entry exists, output is 0, do nothing else
END
ELSE
BEGIN
IF @mode = 'ADD'
BEGIN

SELECT @code = ISNULL(MAX(code) + 10, 0)
FROM   labelfile
WHERE  labeldefinition = @labeldefinition
--	AND abbr = @abbr

IF @code < 10
BEGIN
--could not resolve a good code
SET @error = -1
END

ELSE
BEGIN
INSERT  INTO labelfile
( labeldefinition
,name
,abbr
,code
,locked
,userlabelname
,systemcode
,retired
,inventory_item
)
VALUES  ( @labeldefinition
,@name
,@abbr
,@code
,'N'
,@userlabelname
,'n'
,'N'
,'N'
)

--Succesfully inserted, set output to 1
SET @error = 1
END
END
ELSE
BEGIN
-- could not find the base labeldefinition
SET @error = -2
END
END
END
GO
GRANT EXECUTE ON  [dbo].[tmw_AddLabelFileEntries_sp] TO [public]
GO
