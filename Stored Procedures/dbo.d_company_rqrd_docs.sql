SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_company_rqrd_docs] @cmp_id varchar(8) AS
DECLARE @paperworkmode 	CHAR(1),
        @cmp_name	VARCHAR(100)

SELECT @paperworkmode = gi_string1
  FROM generalinfo
 WHERE gi_name = 'PaperWorkMode'

SELECT @cmp_name = cmp_name
  FROM company
 WHERE cmp_id = @cmp_id

IF @paperworkmode = 'A'
BEGIN
	--PTS 40877 add  bdt_required_for_application, bdt_required_for_fgt_event
   SELECT labelfile.name, @cmp_id cmp_id, @cmp_name cmp_name, 'B', 'B'
     FROM labelfile
    WHERE labelfile.abbr <> 'UNK' AND
          ISNULL(labelfile.retired, 'N') <> 'Y' AND
          labelfile.labeldefinition = 'PaperWork'
END
ELSE
BEGIN
	--PTS 40877 add  bdt_required_for_application, bdt_required_for_fgt_event
   SELECT labelfile.name, billdoctypes.cmp_id cmp_id, @cmp_name cmp_name, bdt_required_for_application, bdt_required_for_fgt_event
     FROM billdoctypes JOIN labelfile ON billdoctypes.bdt_doctype = labelfile.abbr AND
                                         labelfile.abbr <> 'UNK' AND
                                         ISNULL(labelfile.retired, 'N') <> 'Y' AND
                                         labelfile.labeldefinition = 'PaperWork'
    WHERE billdoctypes.cmp_id = @cmp_id AND
          ISNULL(billdoctypes.bdt_inv_required, 'Y') = 'Y'
END

GO
GRANT EXECUTE ON  [dbo].[d_company_rqrd_docs] TO [public]
GO
