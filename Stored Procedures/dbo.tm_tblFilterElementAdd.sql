SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- We are assuming the user has an Admin filter already in tblFilters
-- This should be true since you can't get to the sub admin tab without
--  permissions to at least one group, thus a tblFilters entry.

CREATE PROCEDURE [dbo].[tm_tblFilterElementAdd] 	@LoginName varchar(50),
						@EntryType varchar(20),
						@EntryValue varchar(15),
						@NoView int,
						@NoRead int,
						@NoSend int,
						@PosOnly int,
						@NoOwner int,
						@NoContent int

AS

SET NOCOUNT ON 

DECLARE @FilterSN int,
	@NextSeq int

-- Get flt_SN of the Admin filter
SELECT @FilterSN = ISNULL(flt_SN,-1) 
FROM tblFilters (NOLOCK)
WHERE flt_LoginID = @LoginName
  AND ISNULL(flt_name,'') = ''

-- Get the next sequence number to use
SELECT @NextSeq = ISNULL(MAX(fel_Seq),0)
FROM tblFilterElement  (NOLOCK)
WHERE flt_SN = @FilterSN

SET @NextSeq = @NextSeq + 1

-- Now do the insert
INSERT INTO tblFilterElement (
	flt_SN, 
	fel_Seq, 
	fel_Type, 
	fel_Value, 
	fel_NoView, 	--5

	fel_NoRead, 
	fel_NoSend, 
	fel_PosOnly, 
	fel_NoOwner, 
	fel_NoContent)	--10
VALUES (@FilterSN, 
	@NextSeq, 
	@EntryType,
	@EntryValue,
	@NoView,	--5

	@NoRead,
	@NoSend,
	@PosOnly,
	@NoOwner,
	@NoContent)	--10

GO
GRANT EXECUTE ON  [dbo].[tm_tblFilterElementAdd] TO [public]
GO
