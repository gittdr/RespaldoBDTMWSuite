SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE proc [dbo].[load_label_ptr_sp] @name varchar(20)  as 

/****** Object:  Stored Procedure dbo.load_label_ptr_sp    Script Date: 8/20/97 1:59:22 PM ******/

/**
 * 
 * NAME:
 * dbo.load_label_ptr_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure returns values to labels.
 * 
 *
 * RETURNS:
 *  
 * name,abbr,code to a datawindow.
 * 
 *
 * RESULT SETS: 
 * name,abbr,code to a datawindow.
 *
 * PARAMETERS:
 * 001 - @name, varchar(20), input, null;
 *       This parameter indicates the name which will be looked up 
 *       for the result set to return. The value must be 
 *       non-null and non-empty.
 * 
 *
 * REFERENCES:  NONE 
 *
 * 
 * REVISION HISTORY:
 * 01/17/2005.01 ? PTS35095 - PRB ? Needed to make sure that retired items were not being returned.
 * 01/17/2005.02 - PTS35095 - PRB - Added this section of notes.
 *
 **/

--BEGIN PTS #35095

SELECT name, 
abbr, 
code 
INTO #templabel 
FROM labelfile 
WHERE labeldefinition = @name AND (ISNULL(retired, '') = '' OR retired = 'N')

-- End of PTS #35095

UPDATE #templabel 
SET name = IsNull((SELECT min ( userlabelname ) 
		FROM labelfile 
		WHERE ( userlabelname > '' ) AND 
			( '@' + labeldefinition = #templabel.name )), #templabel.name) 
WHERE name like '@%' 

SELECT name,   
abbr,   
code  
FROM #templabel

GO
GRANT EXECUTE ON  [dbo].[load_label_ptr_sp] TO [public]
GO
