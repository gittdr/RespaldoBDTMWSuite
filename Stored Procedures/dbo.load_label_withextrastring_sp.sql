SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****** Object:  Stored Procedure dbo.load_label_withextrastring_s    Script Date: 8/28/12 ******/

-- DPETE 63725 customer is using extra string1 of label to hold canned message for label BillingMessages


create procedure [dbo].[load_label_withextrastring_sp] @name varchar(20)  as 

SELECT name, 
	abbr, 
	code ,
    case isnull(label_extrastring1,'')
       when '' then name
       else label_extrastring1
       end,
    label_extrastring2
	FROM labelfile 
	WHERE 	labeldefinition = @name AND
		IsNull(retired, 'N') <> 'Y'
	ORDER BY code
GO
GRANT EXECUTE ON  [dbo].[load_label_withextrastring_sp] TO [public]
GO
