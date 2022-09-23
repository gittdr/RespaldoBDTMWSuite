SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****** Object:  Stored Procedure dbo.load_label_sp    Script Date: 8/20/97 1:59:23 PM ******/
-- PTS 46930 add indicator of format supporting roll into line haul to the drop down
--     extrastring1 will have Y


create procedure [dbo].[load_label_invoiceselect_sp] @name varchar(20)  as 
DECLARE @csv  CHAR(1)

SELECT @csv = ISNULL(Upper(Left(gi_string1, 1)), 'N')
  FROM generalinfo
 WHERE gi_name = 'CSVInvoicing'

IF @csv = 'Y'
BEGIN
   select name,abbr,code,label_extrastring1 = isnull(label_extrastring1,'N')
    from labelfile
   where labeldefinition = @name
         and isnull(retired,'N') = 'N'
END
ELSE
BEGIN
   SELECT name, abbr, code, label_extrastring1 = ISNULL(label_extrastring1, 'N')
     FROM labelfile
    WHERE labeldefinition = @name AND
          ISNULL(retired, 'N') = 'N' AND
          RIGHT(name, 3) <> 'csv'
END

GO
GRANT EXECUTE ON  [dbo].[load_label_invoiceselect_sp] TO [public]
GO
