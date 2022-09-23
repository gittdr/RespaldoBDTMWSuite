SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create proc [dbo].[TFCompanyIDLookup]
      @branch varchar(10),
      @cmpid varchar(10),
      @cmpaltid varchar(10)
as
      select C.cmp_id 
      from company C with(nolock)
      INNER JOIN
      (
              company_alternates CA with(nolock)
              INNER JOIN
                        company A with(nolock)
              ON A.cmp_id = CA.ca_alt
                        AND A.cmp_revtype1  = @branch
                        AND A.cmp_altid = @cmpaltid
      )
      ON C.cmp_id = CA.ca_id
GO
GRANT EXECUTE ON  [dbo].[TFCompanyIDLookup] TO [public]
GO
