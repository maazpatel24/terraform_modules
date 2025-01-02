--
-- PostgreSQL database dump
--

-- Dumped from database version 15.7
-- Dumped by pg_dump version 16.3 (Ubuntu 16.3-1.pgdg20.04+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: azure_pg_admin
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO azure_pg_admin;

--
-- Name: pg_cron; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_cron WITH SCHEMA public;


--
-- Name: EXTENSION pg_cron; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_cron IS 'Job scheduler for PostgreSQL';


--
-- Name: devc550schema; Type: SCHEMA; Schema: -; Owner: c550sqladmin
--

CREATE SCHEMA devc550schema;


ALTER SCHEMA devc550schema OWNER TO c550sqladmin;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';


--
-- Name: encrypt_email_pattern(text); Type: FUNCTION; Schema: public; Owner: c550sqladmin
--

CREATE FUNCTION public.encrypt_email_pattern(pattern text) RETURNS text
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN pgp_sym_encrypt(pattern, 'encryption_key');
END;
$$;


ALTER FUNCTION public.encrypt_email_pattern(pattern text) OWNER TO c550sqladmin;

--
-- Name: get_count_end_customers_by_rules(integer); Type: FUNCTION; Schema: public; Owner: c550sqladmin
--

CREATE FUNCTION public.get_count_end_customers_by_rules(user_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    default_rule integer;
    count_end_customers integer;
BEGIN
    SELECT AR.DefaultUserVisibility INTO default_rule FROM approle AR WHERE AR.id = (SELECT AU.approleid FROM appuser AU WHERE AU.id = user_id);
    
    /* All End Customers */
    IF default_rule = 1 OR default_rule = 3 OR default_rule = 5 THEN
        RAISE NOTICE 'Case 1';
        SELECT COUNT(BE.id) INTO count_end_customers FROM businessentity BE INNER JOIN endcustomer EC ON BE.id = EC.businessentityid;
        RETURN count_end_customers;
    END IF;

    /* End Customers Created By My Organization */
    IF default_rule = 4 OR default_rule = 6 THEN
        RAISE NOTICE 'Case 2';
        SELECT COUNT(BE.id) INTO count_end_customers FROM businessentity BE INNER JOIN endcustomer EC ON BE.id = EC.businessentityid 
        WHERE EC.createdbybusinessentityid = (SELECT AU.businessentityid FROM appuser AU WHERE AU.id = user_id);
        RETURN count_end_customers;
    END IF;
    
    -- If no conditions matched, return 0
    RETURN 0;
END;
$$;


ALTER FUNCTION public.get_count_end_customers_by_rules(user_id integer) OWNER TO c550sqladmin;

--
-- Name: jci_get_assetwise_event_statistics(integer, integer); Type: FUNCTION; Schema: public; Owner: c550sqladmin
--

CREATE FUNCTION public.jci_get_assetwise_event_statistics(site_id integer, user_id integer) RETURNS TABLE(assetid character varying, criticalcount integer, alarmcount integer, criticalcountack integer, alarmcountack integer, siteid integer, updatedon timestamp without time zone)
    LANGUAGE plpgsql
    AS $$
DECLARE 
    user_role VARCHAR(100);
BEGIN
    -- Retrieve the user role and business entity based on UserId
    SELECT ar.displayname
    INTO user_role
    FROM appuser au
    JOIN approle ar ON au.approleid = ar.id
    WHERE au.id = user_id;

    -- Based on the user role, perform the respective query
    IF user_role = 'Facility User' THEN
        -- Query 1
        RETURN QUERY
      SELECT 
    COALESCE(eventstatisticsbyasset.assetid, siteassetuser.assetid) AS assetid,
    COALESCE(eventstatisticsbyasset.criticalcount, 0) AS criticalcount,
    COALESCE(eventstatisticsbyasset.alarmcount, 0) AS alarmcount,
    COALESCE(eventstatisticsbyasset.criticalcountack, 0) AS criticalcountack,
    COALESCE(eventstatisticsbyasset.alarmcountack, 0) AS alarmcountack,
    COALESCE(eventstatisticsbyasset.siteid, siteassetuser.siteid) AS siteid,
    COALESCE(eventstatisticsbyasset.updatedon, NULL) AS updatedon
FROM 
    siteassetuser 
LEFT JOIN 
    eventstatisticsbyasset ON siteassetuser.assetid = eventstatisticsbyasset.assetid
WHERE 
    siteassetuser.userid = user_id;
    ELSE
        -- Query 2
        RETURN QUERY
     SELECT 
    COALESCE(eventstatisticsbyasset.assetid, siteasset.assetid) AS assetid,
    COALESCE(eventstatisticsbyasset.criticalcount, 0) AS criticalcount,
    COALESCE(eventstatisticsbyasset.alarmcount, 0) AS alarmcount,
    COALESCE(eventstatisticsbyasset.criticalcountack, 0) AS criticalcountack,
    COALESCE(eventstatisticsbyasset.alarmcountack, 0) AS alarmcountack,
    COALESCE(eventstatisticsbyasset.siteid, siteasset.siteid) AS siteid,
    COALESCE(eventstatisticsbyasset.updatedon, NULL) AS updatedon
FROM 
    siteasset
LEFT JOIN 
    eventstatisticsbyasset ON siteasset.siteid = eventstatisticsbyasset.siteid
                             AND siteasset.assetid = eventstatisticsbyasset.assetid
WHERE 
    siteasset.siteid = site_id ;
    END IF;
END;
$$;


ALTER FUNCTION public.jci_get_assetwise_event_statistics(site_id integer, user_id integer) OWNER TO c550sqladmin;

--
-- Name: jci_get_sitewise_event_statistics(uuid, integer); Type: FUNCTION; Schema: public; Owner: c550sqladmin
--

CREATE FUNCTION public.jci_get_sitewise_event_statistics(end_customer_id uuid, user_id integer) RETURNS TABLE(sitename character varying, siteid integer, criticalcount integer, alarmcount integer, criticalcountack integer, alarmcountack integer, updatedon timestamp without time zone)
    LANGUAGE plpgsql
    AS $$
DECLARE 
    user_role VARCHAR(100);
    business_entity UUID;
BEGIN
    -- Retrieve the user role and business entity based on UserId
    SELECT ar.displayname, au.businessentityid
    INTO user_role, business_entity
    FROM appuser au
    JOIN approle ar ON au.approleid = ar.id
    WHERE au.id = user_id;

    -- Based on the user role, perform the respective query
    IF user_role = 'Field Service Manager' OR user_role = 'Field Service Technician' THEN
        -- Query 1
        RETURN QUERY
SELECT 
    site.sitename,
    COALESCE(eventstatisticsbysite.siteid, site.id) AS siteid,
    COALESCE(eventstatisticsbysite.criticalcount, 0) AS criticalcount,
    COALESCE(eventstatisticsbysite.alarmcount, 0) AS alarmcount,
    COALESCE(eventstatisticsbysite.criticalcountack, 0) AS criticalcountack,
    COALESCE(eventstatisticsbysite.alarmcountack, 0) AS alarmcountack,
    COALESCE(eventstatisticsbysite.updatedon, null) AS updatedon
FROM 
    site
LEFT JOIN 
    eventstatisticsbysite ON site.Id = eventstatisticsbysite.siteId
        WHERE site.endcustomerid = end_customer_id AND site.fieldservicecompanyid = business_entity;
    ELSIF user_role = 'Facility Manager' THEN
        -- Query 2
        RETURN QUERY
      SELECT 
    site.sitename,
    COALESCE(eventstatisticsbysite.siteid, site.id) AS siteid,
    COALESCE(eventstatisticsbysite.criticalcount, 0) AS criticalcount,
    COALESCE(eventstatisticsbysite.alarmcount, 0) AS alarmcount,
    COALESCE(eventstatisticsbysite.criticalcountack, 0) AS criticalcountack,
    COALESCE(eventstatisticsbysite.alarmcountack, 0) AS alarmcountack,
    COALESCE(eventstatisticsbysite.updatedon, NULL) AS updatedon
FROM 
    siteadmin
INNER JOIN 
    site ON siteadmin.siteid = site.id
LEFT JOIN 
    eventstatisticsbysite ON site.id = eventstatisticsbysite.siteId
        WHERE siteadmin.siteadminid = user_id;
    ELSE
        -- Query 3
        RETURN QUERY
      SELECT 
    site.sitename,
    COALESCE(eventstatisticsbysite.siteid, site.id) AS siteid,
    COALESCE(eventstatisticsbysite.criticalcount, 0) AS criticalcount,
    COALESCE(eventstatisticsbysite.alarmcount, 0) AS alarmcount,
    COALESCE(eventstatisticsbysite.criticalcountack, 0) AS criticalcountack,
    COALESCE(eventstatisticsbysite.alarmcountack, 0) AS alarmcountack,
    COALESCE(eventstatisticsbysite.updatedon, null) AS updatedon
FROM 
    site
LEFT JOIN 
    eventstatisticsbysite ON site.Id = eventstatisticsbysite.siteId
        WHERE site.endcustomerid = end_customer_id;
    END IF;
END;
$$;


ALTER FUNCTION public.jci_get_sitewise_event_statistics(end_customer_id uuid, user_id integer) OWNER TO c550sqladmin;

--
-- Name: jci_getactivesubscriptionsminimaldata(uuid, integer); Type: FUNCTION; Schema: public; Owner: c550sqladmin
--

CREATE FUNCTION public.jci_getactivesubscriptionsminimaldata(businessentity_id uuid, license_count integer) RETURNS TABLE(subscriptionid uuid, subscriptionname character varying, shortcode character varying, availablelicensecount bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF license_count IS NULL OR license_count = 0 THEN
        RETURN QUERY
        SELECT DISTINCT
            s.id AS SubscriptionId,
            s.name AS SubscriptionName,
			s.shortcode,
			COUNT(l.subscriptionid) AS AvailableLicenseCount
        FROM
            businessentity be
        JOIN
            subscription s ON be.paymentgatewaycustomerid = s.paymentgatewaycustomerid
        LEFT JOIN
            license l ON s.id = l.subscriptionid
        WHERE
            l.assetid IS NULL
            AND (s.status = 'active' OR s.status = 'trialing')
            AND be.id = businessentity_id
			GROUP BY
    s.id,
    s.name
ORDER BY
    s.id;
	
    ELSE
        RETURN QUERY
        SELECT
             s.id AS SubscriptionId,
            s.name AS SubscriptionName,
			s.shortcode,
			COUNT(l.subscriptionid) AS AvailableLicenseCount
        FROM
            businessentity be
        JOIN
            subscription s ON be.paymentgatewaycustomerid = s.paymentgatewaycustomerid
        LEFT JOIN
            license l ON s.id = l.subscriptionid
        WHERE
            (s.status = 'active' OR s.status = 'trialing')
            AND be.id = businessentity_id
            AND (l.assetid IS NULL OR l.assetid = '')
        GROUP BY
            s.id,
            s.name
        HAVING
            COUNT(l.subscriptionid) >= license_count
        ORDER BY
            s.id;
    END IF;
END;
$$;


ALTER FUNCTION public.jci_getactivesubscriptionsminimaldata(businessentity_id uuid, license_count integer) OWNER TO c550sqladmin;

--
-- Name: jci_getallminimalendcustomer(uuid, character varying); Type: FUNCTION; Schema: public; Owner: c550sqladmin
--

CREATE FUNCTION public.jci_getallminimalendcustomer(businessentityid uuid, searchendcustomer character varying DEFAULT NULL::character varying) RETURNS TABLE(endcustomerid uuid, endcustomerdisplayname character varying, endcustomercontactname character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE
    business_entity_tagkey character varying;
BEGIN
    -- Check business entity type
    SELECT assettagkey INTO business_entity_tagkey FROM businessentitytype WHERE Id = (SELECT businessentitytypeid from businessentity where id = businessentityid);

    IF business_entity_tagkey = 'fsc' THEN
            RETURN QUERY 
            SELECT Id AS EndCustomerId, DisplayName AS EndCustomerDisplayName, ContactName AS EndCustomerContactName
            FROM BusinessEntity
            WHERE Id in (select s.endcustomerid from site s where s.fieldservicecompanyid = businessentityid)
            AND (DisplayName ILIKE '%' || searchEndCustomer || '%' OR ContactName ILIKE '%' || searchEndCustomer || '%');
    ELSE
           	RETURN QUERY 
            SELECT Id AS EndCustomerId, DisplayName AS EndCustomerDisplayName, ContactName AS EndCustomerContactName
            FROM BusinessEntity
            WHERE businessentitytypeid = (select id from businessentitytype where assettagkey = 'endCustomer') AND (DisplayName ILIKE '%' || searchEndCustomer || '%' OR ContactName ILIKE '%' || searchEndCustomer || '%');
        END IF;
END;
$$;


ALTER FUNCTION public.jci_getallminimalendcustomer(businessentityid uuid, searchendcustomer character varying) OWNER TO c550sqladmin;

--
-- Name: jci_getallsites(uuid, character varying, integer, integer, character varying, character varying); Type: FUNCTION; Schema: public; Owner: c550sqladmin
--

CREATE FUNCTION public.jci_getallsites(endcustomer_id uuid, user_name character varying, page_number integer, page_size integer, sorting_col character varying, sort_type character varying) RETURNS TABLE(id integer, sitename character varying, sitehierarchicaltags jsonb, fieldservicecompanyname character varying, fieldservicecompanyid uuid, latitude double precision, longitude double precision)
    LANGUAGE plpgsql
    AS $$
DECLARE ROLE_NAME character varying (200) ;
DECLARE BE_Id uuid;
DECLARE USER_Id int;

BEGIN
    SELECT AU.Id, AR.displayname, AU.businessentityid INTO USER_Id,ROLE_NAME, BE_Id 
	FROM appuser AU
	INNER JOIN approle AR ON AR.id = AU.approleid
	WHERE AU.username = user_name;
	
    /* If logged in user is facility corp admin, then in response all sites belogs to that end customer should come*/
    IF ROLE_NAME = 'Facility Corp Admin' THEN
        RETURN QUERY 
        SELECT
            S.id,
            S.SiteName,
            S.SiteHierarchicalTags,
            BE.DisplayName as FieldServiceCompanyName,
			BE.Id as FieldServiceCompanyId,
			ST_Y(S.location::geometry) AS Latitude, 
			ST_X(S.location::geometry) AS Longitude
        FROM
            site S
            INNER JOIN businessentity BE ON BE.Id = S.FieldServiceCompanyId
		WHERE
			S.EndCustomerId = BE_Id
        ORDER BY
            CASE WHEN sorting_col = 'SiteName' AND sort_type = 'ASC' THEN S.SiteName END,
            CASE WHEN sorting_col = 'SiteName' AND sort_type = 'DESC' THEN S.SiteName END DESC,
            CASE WHEN sorting_col = 'FieldServiceCompany' AND sort_type = 'ASC' THEN BE.DisplayName END,
            CASE WHEN sorting_col = 'FieldServiceCompany' AND sort_type = 'DESC' THEN BE.DisplayName END DESC
        OFFSET (page_number - 1) * page_size
        LIMIT page_size;
		
	/* If logged in user is end customer facility manager then site in which he is site admin will be returned */
    ELSIF ROLE_NAME = 'Facility Manager' THEN
        RETURN QUERY 
        SELECT
            S.id,
            S.SiteName,
            S.SiteHierarchicalTags,
            BE.DisplayName as FieldServiceCompanyName,
			BE.Id as FieldServiceCompanyId,
			ST_Y(S.location::geometry) AS Latitude, 
			ST_X(S.location::geometry) AS Longitude
        FROM
            site S
            INNER JOIN siteadmin SA ON SA.SiteId = S.Id
			INNER JOIN businessentity BE ON BE.Id = S.FieldServiceCompanyId
		WHERE
			SA.SiteAdminId = USER_Id
        ORDER BY
            CASE WHEN sorting_col = 'SiteName' AND sort_type = 'ASC' THEN S.SiteName END,
            CASE WHEN sorting_col = 'SiteName' AND sort_type = 'DESC' THEN S.SiteName END DESC,
            CASE WHEN sorting_col = 'FieldServiceCompany' AND sort_type = 'ASC' THEN BE.DisplayName END,
            CASE WHEN sorting_col = 'FieldServiceCompany' AND sort_type = 'DESC' THEN BE.DisplayName END DESC
        OFFSET (page_number - 1) * page_size
        LIMIT page_size;
		
	/* If logged in user is facility user then site in which he is mapped will be returned */
    ELSIF ROLE_NAME = 'Facility User' THEN
        RETURN QUERY 
        SELECT
            S.id,
            S.SiteName,
            S.SiteHierarchicalTags,
            BE.DisplayName as FieldServiceCompanyName,
			BE.Id as FieldServiceCompanyId,
			ST_Y(S.location::geometry) AS Latitude, 
			ST_X(S.location::geometry) AS Longitude
        FROM
            siteuser SU
            INNER JOIN site S ON S.Id = SU.SiteId
			INNER JOIN businessentity BE ON BE.Id = S.FieldServiceCompanyId
		WHERE
			SU.UserId = USER_Id
        ORDER BY
            CASE WHEN sorting_col = 'SiteName' AND sort_type = 'ASC' THEN S.SiteName END,
            CASE WHEN sorting_col = 'SiteName' AND sort_type = 'DESC' THEN S.SiteName END DESC,
            CASE WHEN sorting_col = 'FieldServiceCompany' AND sort_type = 'ASC' THEN BE.DisplayName END,
            CASE WHEN sorting_col = 'FieldServiceCompany' AND sort_type = 'DESC' THEN BE.DisplayName END DESC
        OFFSET (page_number - 1) * page_size
        LIMIT page_size;
		
	/* If logged in user is a part of fa then site in which he is mapped will be returned */
    ELSIF ROLE_NAME = 'Field Service Manager' OR ROLE_NAME = 'Field Service Technician' THEN
        RETURN QUERY 
        SELECT
            S.id,
            S.SiteName,
            S.SiteHierarchicalTags,
            BE.DisplayName as FieldServiceCompanyName,
			BE.Id as FieldServiceCompanyId,
		    ST_Y(S.location::geometry) AS Latitude, 
			ST_X(S.location::geometry) AS Longitude
        FROM
            site S
            INNER JOIN businessentity BE ON BE.Id = S.FieldServiceCompanyId
		WHERE
			S.EndCustomerId = endcustomer_id AND S.FieldServiceCompanyId = BE_Id
        ORDER BY
            CASE WHEN sorting_col = 'SiteName' AND sort_type = 'ASC' THEN S.SiteName END,
            CASE WHEN sorting_col = 'SiteName' AND sort_type = 'DESC' THEN S.SiteName END DESC,
            CASE WHEN sorting_col = 'FieldServiceCompany' AND sort_type = 'ASC' THEN BE.DisplayName END,
            CASE WHEN sorting_col = 'FieldServiceCompany' AND sort_type = 'DESC' THEN BE.DisplayName END DESC
        OFFSET (page_number - 1) * page_size
        LIMIT page_size;
	
	/* Else sites for selected end customers will be returend */
    ELSE
    	RETURN QUERY 
        SELECT
            S.id,
            S.SiteName,
            S.SiteHierarchicalTags,
            BE.DisplayName as FieldServiceCompanyName,
			BE.Id as FieldServiceCompanyId,
			ST_Y(S.location::geometry) AS Latitude, 
			ST_X(S.location::geometry) AS Longitude
        FROM
            site S
            INNER JOIN businessentity BE ON BE.Id = S.FieldServiceCompanyId
		WHERE
			S.EndCustomerId = endcustomer_id
        ORDER BY
            CASE WHEN sorting_col = 'SiteName' AND sort_type = 'ASC' THEN S.SiteName END,
            CASE WHEN sorting_col = 'SiteName' AND sort_type = 'DESC' THEN S.SiteName END DESC,
            CASE WHEN sorting_col = 'FieldServiceCompany' AND sort_type = 'ASC' THEN BE.DisplayName END,
            CASE WHEN sorting_col = 'FieldServiceCompany' AND sort_type = 'DESC' THEN BE.DisplayName END DESC
        OFFSET (page_number - 1) * page_size
        LIMIT page_size;
	END IF;
END;
$$;


ALTER FUNCTION public.jci_getallsites(endcustomer_id uuid, user_name character varying, page_number integer, page_size integer, sorting_col character varying, sort_type character varying) OWNER TO c550sqladmin;

--
-- Name: jci_getassetcount(uuid, integer); Type: FUNCTION; Schema: public; Owner: c550sqladmin
--

CREATE FUNCTION public.jci_getassetcount(p_businessentityid uuid, p_siteid integer DEFAULT NULL::integer) RETURNS TABLE(assetcount bigint)
    LANGUAGE plpgsql
    AS $$
DECLARE 
    v_assettagkey text;
    v_businessentitytypeid int;

BEGIN
    -- Step 2: Check businessentitytypeid based on businessentityid received in parameter
    IF p_siteid IS NOT NULL AND p_siteid != 0 THEN
            RETURN QUERY
            SELECT COUNT(DISTINCT sa.assetid)
            FROM siteasset sa
            LEFT JOIN license l ON sa.assetid = l.assetid
            WHERE sa.siteid = p_siteid AND (l.enddate > Now());
        ELSE
            RETURN QUERY
      SELECT COUNT(DISTINCT sa.assetid)
            FROM siteasset sa
            JOIN site s ON sa.siteid = s.id
			LEFT JOIN license l ON sa.assetid = l.assetid
            WHERE s.endcustomerid = p_businessentityid AND (l.enddate > Now());
        END IF;
END;
$$;


ALTER FUNCTION public.jci_getassetcount(p_businessentityid uuid, p_siteid integer) OWNER TO c550sqladmin;

--
-- Name: jci_getassettagdetailsbyassetid(text); Type: FUNCTION; Schema: public; Owner: c550sqladmin
--

CREATE FUNCTION public.jci_getassettagdetailsbyassetid(asset_id_input text) RETURNS TABLE(endcustomerbusinessentityid uuid, endcustomername character varying, siteid integer, sitename character varying, sitehierarchicaltags jsonb, endcustomernotificationsettings jsonb, fscnotificationsettings jsonb, fscbusinessentityid uuid, fscname character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    WITH SiteDetails AS (
        SELECT 
            s.id AS siteid,
            s.sitename,
            s.sitehierarchicaltags,
            be_endcustomer.id AS endcustomerbusinessentityid,
            be_endcustomer.displayname AS endcustomername,
            be_fsc.id AS fscbusinessentityid,
            be_fsc.displayname AS fscname,
            ast.assettags
        FROM 
            site s
        JOIN 
            siteasset sa ON sa.siteid = s.id
        JOIN 
            asset ast ON ast.id = sa.assetid
        JOIN 
            businessentity be_endcustomer ON s.endcustomerid = be_endcustomer.id
        JOIN 
            businessentity be_fsc ON s.fieldservicecompanyid = be_fsc.id
        WHERE 
            sa.assetid = asset_id_input
    ),
    NotificationSettings AS (
        SELECT 
            sd.siteid,
            jsonb_array_elements_text(sd.assettags->'FSCNotificationSettings'->'sms') AS fsc_sms_user_id,
            jsonb_array_elements_text(sd.assettags->'FSCNotificationSettings'->'email') AS fsc_email_user_id,
            jsonb_array_elements_text(sd.assettags->'EndCustomerNotificationSettings'->'sms') AS ec_sms_user_id,
            jsonb_array_elements_text(sd.assettags->'EndCustomerNotificationSettings'->'email') AS ec_email_user_id
        FROM 
            SiteDetails sd
    )
    SELECT 
        sd.endcustomerbusinessentityid,
        sd.endcustomername,
        sd.siteid,
        sd.sitename,
        sd.sitehierarchicaltags,
        jsonb_build_object(
            'sms', jsonb_agg(DISTINCT jsonb_build_object('displayName', appuser_ec_sms.firstname || ' ' || appuser_ec_sms.lastname, 'username', appuser_ec_sms.username)) 
                   FILTER (WHERE appuser_ec_sms.username IS NOT NULL AND appuser_ec_sms.firstname IS NOT NULL AND appuser_ec_sms.lastname IS NOT NULL),
            'email', jsonb_agg(DISTINCT jsonb_build_object('displayName', appuser_ec_email.firstname || ' ' || appuser_ec_email.lastname, 'username', appuser_ec_email.username)) 
                   FILTER (WHERE appuser_ec_email.username IS NOT NULL AND appuser_ec_email.firstname IS NOT NULL AND appuser_ec_email.lastname IS NOT NULL)
        ) AS endcustomernotificationsettings,
        jsonb_build_object(
            'sms', jsonb_agg(DISTINCT jsonb_build_object('displayName', appuser_sms.firstname || ' ' || appuser_sms.lastname, 'username', appuser_sms.username)) 
                   FILTER (WHERE appuser_sms.username IS NOT NULL AND appuser_sms.firstname IS NOT NULL AND appuser_sms.lastname IS NOT NULL),
            'email', jsonb_agg(DISTINCT jsonb_build_object('displayName', appuser_email.firstname || ' ' || appuser_email.lastname, 'username', appuser_email.username)) 
                   FILTER (WHERE appuser_email.username IS NOT NULL AND appuser_email.firstname IS NOT NULL AND appuser_email.lastname IS NOT NULL)
        ) AS fscnotificationsettings,
        sd.fscbusinessentityid,
        sd.fscname
    FROM 
        SiteDetails sd
    LEFT JOIN 
        NotificationSettings ns ON ns.siteid = sd.siteid
    LEFT JOIN 
        appuser AS appuser_sms ON appuser_sms.username = ns.fsc_sms_user_id
    LEFT JOIN 
        appuser AS appuser_email ON appuser_email.username = ns.fsc_email_user_id
    LEFT JOIN 
        appuser AS appuser_ec_sms ON appuser_ec_sms.username = ns.ec_sms_user_id
    LEFT JOIN 
        appuser AS appuser_ec_email ON appuser_ec_email.username = ns.ec_email_user_id
    GROUP BY 
        sd.endcustomerbusinessentityid,
        sd.endcustomername,
        sd.siteid,
        sd.sitename,
        sd.sitehierarchicaltags,
        sd.fscbusinessentityid,
        sd.fscname;

END;
$$;


ALTER FUNCTION public.jci_getassettagdetailsbyassetid(asset_id_input text) OWNER TO c550sqladmin;

--
-- Name: jci_getbulkoperations(character varying, character varying, character varying, integer, integer); Type: FUNCTION; Schema: public; Owner: c550sqladmin
--

CREATE FUNCTION public.jci_getbulkoperations(p_username character varying, p_sortingcol character varying, p_sorttype character varying, p_pagenumber integer, p_pagesize integer) RETURNS TABLE(jobid character varying, jobtype character varying, sitename character varying, targetdevicecount integer, scheduledon timestamp without time zone, status character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE
    Approle varchar;
    BussinessEntityId uuid;
BEGIN
    -- Fetch the default rule for the user
    SELECT AR.displayname INTO Approle
    FROM AppRole AR
    WHERE AR.Id = (SELECT AU.AppRoleId FROM AppUser AU WHERE AU.UserName = p_UserName);
    SELECT AU.businessentityid INTO BussinessEntityId FROM AppUser AU WHERE AU.UserName = p_UserName;

    -- All Users
    IF Approle = 'JCI Admin' THEN
        RETURN QUERY
        SELECT bo.jobid, bo.jobtype, s.sitename, bo.targetdevicecount, bo.scheduledon, bo.status
        FROM  BulkOperation bo
		Left JOIN site s ON (bo.target->>'siteid')::int = s.id
        ORDER BY
            CASE WHEN p_SortingCol = 'JobId' AND p_SortType = 'ASC' THEN bo.jobid END,
            CASE WHEN p_SortingCol = 'JobId' AND p_SortType = 'DESC' THEN bo.jobid END DESC,
            CASE WHEN p_SortingCol = 'JobType' AND p_SortType = 'ASC' THEN bo.jobtype END,
            CASE WHEN p_SortingCol = 'JobType' AND p_SortType = 'DESC' THEN bo.jobtype END DESC,
            CASE WHEN p_SortingCol = 'TargetDeviceCount' AND p_SortType = 'ASC' THEN bo.targetdevicecount END,
            CASE WHEN p_SortingCol = 'TargetDeviceCount' AND p_SortType = 'DESC' THEN bo.targetdevicecount END DESC,
            CASE WHEN p_SortingCol = 'ScheduledOn' AND p_SortType = 'ASC' THEN bo.scheduledon END,
            CASE WHEN p_SortingCol = 'ScheduledOn' AND p_SortType = 'DESC' THEN bo.scheduledon END DESC
        OFFSET (p_PageNumber-1) * p_PageSize
        LIMIT p_PageSize;
    END IF;
    
    IF Approle = 'Field Service Manager' OR Approle = 'Field Service Technician' THEN
        RETURN QUERY
        SELECT bo.jobid, bo.jobtype, s.sitename, bo.targetdevicecount, bo.scheduledon, bo.status
        FROM  BulkOperation bo
        Left JOIN site s ON (bo.target->>'siteid')::int = s.id
        WHERE s.fieldservicecompanyid = BussinessEntityId
        ORDER BY
            CASE WHEN p_SortingCol = 'JobId' AND p_SortType = 'ASC' THEN bo.jobid END,
            CASE WHEN p_SortingCol = 'JobId' AND p_SortType = 'DESC' THEN bo.jobid END DESC,
            CASE WHEN p_SortingCol = 'JobType' AND p_SortType = 'ASC' THEN bo.jobtype END,
            CASE WHEN p_SortingCol = 'JobType' AND p_SortType = 'DESC' THEN bo.jobtype END DESC,
            CASE WHEN p_SortingCol = 'TargetDeviceCount' AND p_SortType = 'ASC' THEN bo.targetdevicecount END,
            CASE WHEN p_SortingCol = 'TargetDeviceCount' AND p_SortType = 'DESC' THEN bo.targetdevicecount END DESC,
            CASE WHEN p_SortingCol = 'ScheduledOn' AND p_SortType = 'ASC' THEN bo.scheduledon END,
            CASE WHEN p_SortingCol = 'ScheduledOn' AND p_SortType = 'DESC' THEN bo.scheduledon END DESC
        OFFSET (p_PageNumber-1) * p_PageSize
        LIMIT p_PageSize;
    END IF;
END;
$$;


ALTER FUNCTION public.jci_getbulkoperations(p_username character varying, p_sortingcol character varying, p_sorttype character varying, p_pagenumber integer, p_pagesize integer) OWNER TO c550sqladmin;

--
-- Name: jci_getbulkoperationstotalrows(character varying); Type: FUNCTION; Schema: public; Owner: c550sqladmin
--

CREATE FUNCTION public.jci_getbulkoperationstotalrows(p_username character varying) RETURNS TABLE(totalrows bigint)
    LANGUAGE plpgsql
    AS $$
DECLARE
    Approle varchar;
    BussinessEntityId uuid;
BEGIN
    -- Fetch the default rule for the user
    SELECT AR.displayname INTO Approle
    FROM AppRole AR
    WHERE AR.Id = (SELECT AU.AppRoleId FROM AppUser AU WHERE AU.UserName = p_UserName);
    SELECT AU.businessentityid INTO BussinessEntityId FROM AppUser AU WHERE AU.UserName = p_UserName;

    -- All Users
    IF Approle = 'JCI Admin' THEN
        RETURN QUERY
         SELECT COUNT(bo.jobid) AS TotalRows FROM BulkOperation bo;
    END IF;
    
    IF Approle = 'Field Service Manager' OR Approle = 'Field Service Technician' THEN
        RETURN QUERY
         SELECT COUNT(bo.jobid) AS TotalRows FROM BulkOperation bo
            JOIN site s ON (bo.target->>'siteid')::int = s.id
            WHERE s.fieldservicecompanyid = BussinessEntityId;
    END IF;
END;
$$;


ALTER FUNCTION public.jci_getbulkoperationstotalrows(p_username character varying) OWNER TO c550sqladmin;

--
-- Name: jci_getbusinessentitiescount(character varying, integer); Type: FUNCTION; Schema: public; Owner: c550sqladmin
--

CREATE FUNCTION public.jci_getbusinessentitiescount(user_id character varying, type_id integer) RETURNS TABLE(businessentitycount bigint)
    LANGUAGE plpgsql
    AS $$
DECLARE BET_Key character(50);
DECLARE BE_Id uuid;
 
BEGIN
 
SELECT BET.assettagkey, AU.businessentityid
INTO BET_Key , BE_Id
FROM appuser AU
INNER JOIN businessentity BE ON BE.id = AU.businessentityid
INNER JOIN businessentitytype BET ON BET.id = BE.businessentitytypeid
WHERE AU.username = user_id;
 
IF BET_Key = 'customerSupportProvider' and type_id = 2 THEN 
     RETURN QUERY SELECT Count(BE.id)
                      FROM BusinessEntity BE WHERE BE.id = BE_Id;
  ELSE
	 RETURN QUERY SELECT Count(BE.id)
                      FROM BusinessEntity BE
                      WHERE BE.BusinessEntityTypeId = type_id
                      AND BE.BusinessEntityTypeId != (SELECT BETT.Id FROM BusinessEntityType BETT WHERE BETT.AssetTagKey = 'endCustomer');
END IF;				  
END;
$$;


ALTER FUNCTION public.jci_getbusinessentitiescount(user_id character varying, type_id integer) OWNER TO c550sqladmin;

--
-- Name: jci_getbusinessentitieswithoutpagination(character varying, integer, character varying); Type: FUNCTION; Schema: public; Owner: c550sqladmin
--

CREATE FUNCTION public.jci_getbusinessentitieswithoutpagination(user_id character varying, type_id integer, secret_key character varying) RETURNS TABLE(id uuid, displayname character varying, businessentitytypeid integer, contactname character varying, contactnumber text, contactemail text, address jsonb)
    LANGUAGE plpgsql
    AS $$
DECLARE BET_Key character(50);
DECLARE BE_Id uuid;
 
BEGIN
 
SELECT BET.assettagkey, AU.businessentityid
INTO BET_Key , BE_Id
FROM appuser AU
INNER JOIN businessentity BE ON BE.id = AU.businessentityid
INNER JOIN businessentitytype BET ON BET.id = BE.businessentitytypeid
WHERE AU.username = user_id;
 
IF BET_Key = 'customerSupportProvider' and type_id = 2 THEN 
     RETURN QUERY SELECT BE.Id, BE.DisplayName, BE.BusinessEntityTypeId, BE.ContactName, pgp_sym_decrypt(BE.ContactNumber, secret_key) AS ContactNumber, 
pgp_sym_decrypt(BE.ContactEmail, secret_key) AS ContactEmail, BE.Address
                      FROM BusinessEntity BE WHERE BE.id = BE_Id;
  ELSE
	 RETURN QUERY SELECT BE.Id, BE.DisplayName, BE.BusinessEntityTypeId, BE.ContactName, pgp_sym_decrypt(BE.ContactNumber, secret_key) AS ContactNumber, 
pgp_sym_decrypt(BE.ContactEmail, secret_key) AS ContactEmail, BE.Address
                      FROM BusinessEntity BE
                      WHERE BE.BusinessEntityTypeId = type_id
                      AND BE.BusinessEntityTypeId != (SELECT BETT.Id FROM BusinessEntityType BETT WHERE BETT.AssetTagKey = 'endCustomer');
END IF;				  
END;
$$;


ALTER FUNCTION public.jci_getbusinessentitieswithoutpagination(user_id character varying, type_id integer, secret_key character varying) OWNER TO c550sqladmin;

--
-- Name: jci_getbusinessentitieswithpagination(character varying, integer, integer, integer, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: c550sqladmin
--

CREATE FUNCTION public.jci_getbusinessentitieswithpagination(user_id character varying, type_id integer, page_number integer, page_size integer, sorting_col character varying, sort_type character varying, secret_key character varying) RETURNS TABLE(id uuid, displayname character varying, businessentitytypeid integer, contactname character varying, contactnumber text, contactemail text, address jsonb)
    LANGUAGE plpgsql
    AS $$
DECLARE BET_Key character(50);
DECLARE BE_Id uuid;
 
BEGIN
 
SELECT BET.assettagkey, AU.businessentityid
INTO BET_Key , BE_Id
FROM appuser AU
INNER JOIN businessentity BE ON BE.id = AU.businessentityid
INNER JOIN businessentitytype BET ON BET.id = BE.businessentitytypeid
WHERE AU.username = user_id;
 
IF BET_Key = 'customerSupportProvider' and type_id = 2 THEN 
     RETURN QUERY SELECT BE.Id, BE.DisplayName, BE.BusinessEntityTypeId, BE.ContactName, pgp_sym_decrypt(BE.ContactNumber, secret_key) AS ContactNumber, 
pgp_sym_decrypt(BE.ContactEmail, secret_key) AS ContactEmail, BE.Address
                      FROM BusinessEntity BE WHERE BE.id = BE_Id
					  ORDER BY CASE WHEN sorting_col = 'DisplayName' AND sort_type = 'ASC' THEN BE.DisplayName END , CASE WHEN sorting_col = 'DisplayName' AND sort_type = 'DESC'
THEN BE.DisplayName END DESC, CASE WHEN sorting_col = 'ContactName' AND sort_type = 'ASC' THEN BE.ContactName END , CASE WHEN sorting_col = 'ContactName'
AND sort_type = 'DESC' THEN BE.ContactName END DESC, CASE WHEN sorting_col = 'ContactEmail' AND sort_type = 'ASC' THEN BE.ContactEmail END ,
CASE WHEN sorting_col = 'ContactEmail' AND sort_type = 'DESC' THEN BE.ContactEmail END DESC OFFSET (page_number-1)*page_size LIMIT page_size;
  ELSE
	 RETURN QUERY SELECT BE.Id, BE.DisplayName, BE.BusinessEntityTypeId, BE.ContactName, pgp_sym_decrypt(BE.ContactNumber, secret_key) AS ContactNumber, 
pgp_sym_decrypt(BE.ContactEmail, secret_key) AS ContactEmail, BE.Address
                      FROM BusinessEntity BE
                      WHERE BE.BusinessEntityTypeId = type_id
                      AND BE.BusinessEntityTypeId != (SELECT BETT.Id FROM BusinessEntityType BETT WHERE BETT.AssetTagKey = 'endCustomer')
					  ORDER BY CASE WHEN sorting_col = 'DisplayName' AND sort_type = 'ASC' THEN BE.DisplayName END , CASE WHEN sorting_col = 'DisplayName' AND sort_type = 'DESC'
THEN BE.DisplayName END DESC, CASE WHEN sorting_col = 'ContactName' AND sort_type = 'ASC' THEN BE.ContactName END , CASE WHEN sorting_col = 'ContactName'
AND sort_type = 'DESC' THEN BE.ContactName END DESC, CASE WHEN sorting_col = 'ContactEmail' AND sort_type = 'ASC' THEN BE.ContactEmail END ,
CASE WHEN sorting_col = 'ContactEmail' AND sort_type = 'DESC' THEN BE.ContactEmail END DESC OFFSET (page_number-1)*page_size LIMIT page_size;
END IF;				  
END;
$$;


ALTER FUNCTION public.jci_getbusinessentitieswithpagination(user_id character varying, type_id integer, page_number integer, page_size integer, sorting_col character varying, sort_type character varying, secret_key character varying) OWNER TO c550sqladmin;

--
-- Name: jci_getcountryandstatewiseassetcount(uuid, text); Type: FUNCTION; Schema: public; Owner: c550sqladmin
--

CREATE FUNCTION public.jci_getcountryandstatewiseassetcount(p_businessentityid uuid, p_city text DEFAULT NULL::text) RETURNS TABLE(countryname text, statename text, assetcount bigint)
    LANGUAGE plpgsql
    AS $$
DECLARE 
	v_assettagkey text;
    v_businessentitytypeid int;

BEGIN
    -- Step 2: Check businessentitytypeid based on businessentityid received in parameter
    SELECT businessentitytypeid INTO v_businessentitytypeid
    FROM businessentity
    WHERE id = p_businessentityid;
	
	SELECT assettagkey INTO v_assettagkey
    FROM businessentitytype
    WHERE id = v_businessentitytypeid;
	
    -- Step 3: Determine the appropriate query based on businessentitytypeid and city parameter
    IF v_assettagkey IN ('serviceProvider', 'customerSupportProvider') THEN
        IF p_city IS NULL THEN
            -- Step 4: businessentitytypeid is 1 or 2 and city is null
            RETURN QUERY
            SELECT jsonb_extract_path_text(sitehierarchicaltags, 'Country') AS CountryName,
                   NULL AS StateName,
                   COUNT(sa.assetId) AS AssetCount
            FROM site AS s
            INNER JOIN siteAsset AS sa ON s.id = sa.siteId
            GROUP BY jsonb_extract_path_text(sitehierarchicaltags, 'Country');
        ELSE
            -- Step 5: businessentitytypeid is 1 or 2 and city is not null
            RETURN QUERY
            SELECT NULL AS CountryName,
                   jsonb_extract_path_text(sitehierarchicaltags, 'State') AS StateName,
                   COUNT(sa.assetId) AS AssetCount
            FROM site AS s
            INNER JOIN siteAsset AS sa ON s.id = sa.siteId
            WHERE jsonb_extract_path_text(sitehierarchicaltags, 'Country') = p_city
            GROUP BY jsonb_extract_path_text(sitehierarchicaltags, 'State');
        END IF;
    ELSE IF v_assettagkey = 'fsc' THEN
        IF p_city IS NULL THEN
            -- Step 6: businessentitytypeid is not 1 or 2 and city is null
            RETURN QUERY
            SELECT jsonb_extract_path_text(s.sitehierarchicaltags, 'Country') AS CountryName,
                   NULL AS StateName,
                   COUNT(sa.assetId) AS AssetCount
            FROM site AS s
            INNER JOIN siteAsset AS sa ON s.id = sa.siteId
            WHERE s.fieldservicecompanyid = p_businessentityid
            GROUP BY jsonb_extract_path_text(s.sitehierarchicaltags, 'Country');
        ELSE
            -- Step 7: businessentitytypeid is not 1 or 2 and city is not null
            RETURN QUERY
            SELECT NULL AS CountryName,
                   jsonb_extract_path_text(s.sitehierarchicaltags, 'State') AS StateName,
                   COUNT(sa.assetId) AS AssetCount
            FROM site AS s
            INNER JOIN siteAsset AS sa ON s.id = sa.siteId
            WHERE s.fieldservicecompanyid = p_businessentityid
            AND jsonb_extract_path_text(sitehierarchicaltags, 'Country') = p_city
            GROUP BY jsonb_extract_path_text(s.sitehierarchicaltags, 'State');
        END IF;
    END IF;
END IF;
END;
$$;


ALTER FUNCTION public.jci_getcountryandstatewiseassetcount(p_businessentityid uuid, p_city text) OWNER TO c550sqladmin;

--
-- Name: jci_getendcustomerscount(character varying); Type: FUNCTION; Schema: public; Owner: c550sqladmin
--

CREATE FUNCTION public.jci_getendcustomerscount(user_id character varying) RETURNS TABLE(endcustomercount bigint)
    LANGUAGE plpgsql
    AS $$
DECLARE BET_Key character(50);
DECLARE BE_Id uuid;
BEGIN
    SELECT BET.assettagkey, AU.businessentityid
INTO BET_Key , BE_Id
FROM appuser AU
INNER JOIN businessentity BE ON BE.id = AU.businessentityid
INNER JOIN businessentitytype BET ON BET.id = BE.businessentitytypeid
WHERE AU.username = user_id;
    
    /* All End Customers */
    IF BET_Key != 'fsc' THEN
        RAISE NOTICE 'All End Customers';
        RETURN QUERY 
        SELECT
            COUNT(BE.id) as EndCustomerCount
        FROM
            businessentity BE
            INNER JOIN endcustomer EC ON BE.id = EC.businessentityid;
    
    ELSE
    	RETURN QUERY 
        SELECT
            COUNT(BE.id) as EndCustomerCount
        FROM
            businessentity BE
            INNER JOIN endcustomer EC ON BE.Id = EC.BusinessEntityId
			WHERE BE.id in (select S.endcustomerid from site S where S.fieldservicecompanyid = BE_Id)
			OR EC.createdbybusinessentityid = BE_Id;
	END IF;
END;
$$;


ALTER FUNCTION public.jci_getendcustomerscount(user_id character varying) OWNER TO c550sqladmin;

--
-- Name: jci_getendcustomerswithpagination(character varying, integer, integer, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: c550sqladmin
--

CREATE FUNCTION public.jci_getendcustomerswithpagination(user_id character varying, page_number integer, page_size integer, sorting_col character varying, sort_type character varying, secretkey character varying) RETURNS TABLE(id uuid, displayname character varying, contactnumber text, contactname character varying, contactemail text, address jsonb, isactive boolean, businessentitytypeid integer)
    LANGUAGE plpgsql
    AS $$
DECLARE BET_Key character(50);
DECLARE BE_Id uuid;
BEGIN
    SELECT BET.assettagkey, AU.businessentityid
INTO BET_Key , BE_Id
FROM appuser AU
INNER JOIN businessentity BE ON BE.id = AU.businessentityid
INNER JOIN businessentitytype BET ON BET.id = BE.businessentitytypeid
WHERE AU.username = user_id;
    /* All End Customers */
    IF BET_Key != 'fsc' THEN
        RAISE NOTICE 'All End Customers';
        RETURN QUERY 
        SELECT
            BE.id,
            BE.DisplayName,
            pgp_sym_decrypt(BE.ContactNumber, secretKey),
            BE.ContactName,
            pgp_sym_decrypt(BE.ContactEmail, secretKey),
            BE.Address,
            BE.Isactive,
            BE.BusinessentityTypeId
        FROM
            businessentity BE
            INNER JOIN endcustomer EC ON BE.Id = EC.BusinessEntityId
        ORDER BY
            CASE WHEN sorting_col = 'displayName' AND sort_type = 'ASC' THEN BE.DisplayName END,
            CASE WHEN sorting_col = 'displayName' AND sort_type = 'DESC' THEN BE.DisplayName END DESC,
            CASE WHEN sorting_col = 'contactNumber' AND sort_type = 'ASC' THEN BE.ContactNumber END,
            CASE WHEN sorting_col = 'contactNumber' AND sort_type = 'DESC' THEN BE.ContactNumber END DESC,
            CASE WHEN sorting_col = 'contactName' AND sort_type = 'ASC' THEN BE.ContactName END,
            CASE WHEN sorting_col = 'contactName' AND sort_type = 'DESC' THEN BE.ContactName END DESC,
            CASE WHEN sorting_col = 'contactEmail' AND sort_type = 'ASC' THEN BE.ContactEmail END,
            CASE WHEN sorting_col = 'contactEmail' AND sort_type = 'DESC' THEN BE.ContactEmail END DESC,
            CASE WHEN sorting_col = 'address' AND sort_type = 'ASC' THEN BE.address END,
            CASE WHEN sorting_col = 'address' AND sort_type = 'DESC' THEN BE.address END DESC
        OFFSET (page_number - 1) * page_size
        LIMIT page_size;
    ELSE
    	RETURN QUERY 
        SELECT 
			BE.id,
            BE.DisplayName,
            pgp_sym_decrypt(BE.ContactNumber, secretKey),
            BE.ContactName,
            pgp_sym_decrypt(BE.ContactEmail, secretKey),
            BE.Address,
            BE.Isactive,
            BE.BusinessentityTypeId
        FROM
            businessentity BE
            INNER JOIN endcustomer EC ON BE.Id = EC.BusinessEntityId
			WHERE BE.id in (select S.endcustomerid from site S where S.fieldservicecompanyid = BE_Id)
			OR EC.createdbybusinessentityid = BE_Id
        ORDER BY
            CASE WHEN sorting_col = 'displayName' AND sort_type = 'ASC' THEN BE.DisplayName END,
            CASE WHEN sorting_col = 'displayName' AND sort_type = 'DESC' THEN BE.DisplayName END DESC,
            CASE WHEN sorting_col = 'contactNumber' AND sort_type = 'ASC' THEN BE.ContactNumber END,
            CASE WHEN sorting_col = 'contactNumber' AND sort_type = 'DESC' THEN BE.ContactNumber END DESC,
            CASE WHEN sorting_col = 'contactName' AND sort_type = 'ASC' THEN BE.ContactName END,
            CASE WHEN sorting_col = 'contactName' AND sort_type = 'DESC' THEN BE.ContactName END DESC,
            CASE WHEN sorting_col = 'contactEmail' AND sort_type = 'ASC' THEN BE.ContactEmail END,
            CASE WHEN sorting_col = 'contactEmail' AND sort_type = 'DESC' THEN BE.ContactEmail END DESC,
            CASE WHEN sorting_col = 'address' AND sort_type = 'ASC' THEN BE.address END,
            CASE WHEN sorting_col = 'address' AND sort_type = 'DESC' THEN BE.address END DESC
            
        OFFSET (page_number - 1) * page_size
        LIMIT page_size;
	END IF;
END;
$$;


ALTER FUNCTION public.jci_getendcustomerswithpagination(user_id character varying, page_number integer, page_size integer, sorting_col character varying, sort_type character varying, secretkey character varying) OWNER TO c550sqladmin;

--
-- Name: jci_getlicensesbysubscriptionidwithpagination(uuid, integer, integer, character varying, character varying); Type: FUNCTION; Schema: public; Owner: c550sqladmin
--

CREATE OR REPLACE FUNCTION public.jci_getlicensesbysubscriptionidwithpagination(
	subscription_id uuid,
	page_number integer,
	page_size integer,
	sorting_col character varying,
	sort_type character varying)
    RETURNS TABLE(id uuid, licensekey character varying, startdate timestamp without time zone, enddate timestamp without time zone, isactive boolean, assetid character varying, displayname character varying, appliedon timestamp without time zone, createdon timestamp without time zone, updatedon timestamp without time zone, subscriptionid uuid, action character varying) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
DECLARE
    query text;
BEGIN
    query := format('
        SELECT 
            l.id,
            licensekey,
            startdate,
            enddate,
            isactive,
            assetid,
		    a.displayname AS displayname,
            appliedon,
            l.createdon,
            l.updatedon,
            subscriptionid,
            action
        FROM 
            public.license l
        left join 
            public.asset a ON l.assetid = a.id
        WHERE  
            subscriptionid = %L
        ORDER BY %I %s
        OFFSET %L LIMIT %L',
        subscription_id, sorting_col, sort_type, (page_number - 1) * page_size, page_size);

    RETURN QUERY EXECUTE query;
END;
$BODY$;

ALTER FUNCTION public.jci_getlicensesbysubscriptionidwithpagination(uuid, integer, integer, character varying, character varying)
    OWNER TO c550sqladmin;

--
-- Name: jci_getnotificationsettingsbyassetid(text); Type: FUNCTION; Schema: public; Owner: c550sqladmin
--

CREATE FUNCTION public.jci_getnotificationsettingsbyassetid(asset_id_input text) RETURNS TABLE(endcustomerbusinessentityid uuid, endcustomername text, siteid integer, sitename text, sitehierarchicaltags text, endcustomernotificationsettings jsonb, fscnotificationsettings jsonb)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    WITH NotificationSettings AS (
        SELECT 
            s.id AS siteid,
            jsonb_array_elements_text(ast.assettags->'FSCNotificationSettings'->'sms') AS fsc_sms_user_id,
            jsonb_array_elements_text(ast.assettags->'FSCNotificationSettings'->'email') AS fsc_email_user_id,
            jsonb_array_elements_text(ast.assettags->'EndCustomerNotificationSettings'->'sms') AS ec_sms_user_id,
            jsonb_array_elements_text(ast.assettags->'EndCustomerNotificationSettings'->'email') AS ec_email_user_id
        FROM 
            site s
        JOIN 
            siteasset sa ON sa.siteid = s.id 
        JOIN 
            asset ast ON ast.id = sa.assetid
        WHERE 
            sa.assetid = asset_id_input
    )
    SELECT 
        be.id AS endcustomerbusinessentityid,
        be.contactname AS endcustomername,
        s.id AS siteid,
        s.sitename,
        s.sitehierarchicaltags,
        jsonb_build_object(
            'sms', jsonb_agg(DISTINCT jsonb_build_object('displayName', appuser_sms.firstname || ' ' || appuser_sms.lastname, 'username', appuser_sms.username)),
            'email', jsonb_agg(DISTINCT jsonb_build_object('displayName', appuser_email.firstname || ' ' || appuser_email.lastname, 'username', appuser_email.username))
        ) AS endcustomernotificationsettings,
        jsonb_build_object(
            'sms', jsonb_agg(DISTINCT jsonb_build_object('displayName', appuser_ec_sms.firstname || ' ' || appuser_ec_sms.lastname, 'username', appuser_ec_sms.username)),
            'email', jsonb_agg(DISTINCT jsonb_build_object('displayName', appuser_ec_email.firstname || ' ' || appuser_ec_email.lastname, 'username', appuser_ec_email.username))
        ) AS fscnotificationsettings
    FROM 
        businessentity be
    JOIN 
        site s ON s.endcustomerid = be.id
    JOIN 
        siteasset sa ON sa.siteid = s.id 
    JOIN 
        asset ast ON ast.id = sa.assetid
    LEFT JOIN 
        NotificationSettings ns ON ns.siteid = s.id
    LEFT JOIN 
        appuser AS appuser_sms ON appuser_sms.username = ns.fsc_sms_user_id
    LEFT JOIN 
        appuser AS appuser_email ON appuser_email.username = ns.fsc_email_user_id
    LEFT JOIN 
        appuser AS appuser_ec_sms ON appuser_ec_sms.username = ns.ec_sms_user_id
    LEFT JOIN 
        appuser AS appuser_ec_email ON appuser_ec_email.username = ns.ec_email_user_id
    GROUP BY 
        be.id,
        be.contactname,
        s.id,
        s.sitename,
        s.sitehierarchicaltags;

END;
$$;


ALTER FUNCTION public.jci_getnotificationsettingsbyassetid(asset_id_input text) OWNER TO c550sqladmin;

--
-- Name: jci_getsiteminimaldetails(uuid, uuid, integer); Type: FUNCTION; Schema: public; Owner: c550sqladmin
--

CREATE FUNCTION public.jci_getsiteminimaldetails(end_customer_id uuid, business_entity_id uuid, userid integer) RETURNS TABLE(siteid integer, sitename character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE 
    business_entity_type_id INT;
    user_role_name VARCHAR(100);
BEGIN
    -- Check business entity type
    SELECT BusinessEntityTypeId INTO business_entity_type_id FROM BusinessEntity WHERE Id = business_entity_id;

    -- Check user role
    SELECT r.DisplayName INTO user_role_name
    FROM AppUser u
    INNER JOIN AppRole r ON u.AppRoleId = r.Id
    WHERE u.Id = userId;

    IF user_role_name = 'Facility Manager' THEN
        -- Execute query for Facility Manager
        RETURN QUERY
        SELECT sa.SiteId, s.SiteName
        FROM SiteAdmin sa
        INNER JOIN Site s ON sa.SiteId = s.Id
        WHERE sa.SiteAdminId = userId;
    ELSIF business_entity_type_id = 3 THEN
        -- Execute query for entity ID
        RETURN QUERY
        SELECT s.Id AS SiteId, s.SiteName
        FROM Site s
        WHERE s.EndCustomerId = end_customer_id AND s.FieldServiceCompanyId = business_entity_id;
    ELSE
        -- Execute query for end customer
        RETURN QUERY
        SELECT s.Id AS SiteId, s.SiteName
        FROM Site s
        WHERE s.EndCustomerId = end_customer_id;
    END IF;
END;
$$;


ALTER FUNCTION public.jci_getsiteminimaldetails(end_customer_id uuid, business_entity_id uuid, userid integer) OWNER TO c550sqladmin;

--
-- Name: jci_getsites(uuid, character varying, integer, integer, character varying, character varying); Type: FUNCTION; Schema: public; Owner: c550sqladmin
--

CREATE FUNCTION public.jci_getsites(endcutomer_id uuid, user_name character varying, page_number integer, page_size integer, sorting_col character varying, sort_type character varying) RETURNS TABLE(id integer, sitename character varying, sitehierarchicaltags jsonb, fieldservicecompanyname character varying, fieldservicecompanyid uuid, latitude double precision, longitude double precision)
    LANGUAGE plpgsql
    AS $$
DECLARE ROLE_NAME character varying (200) ;
DECLARE BE_Id uuid;
DECLARE USER_Id int;

BEGIN
    SELECT AU.Id, AR.displayname, AU.businessentityid INTO USER_Id,ROLE_NAME, BE_Id 
	FROM appuser AU
	INNER JOIN approle AR ON AR.id = AU.approleid
	WHERE AU.username = user_name;
	
    /* If logged in user is facility corp admin, then in response all sites belogs to that end customer should come*/
    IF ROLE_NAME = 'Facility Corp Admin' THEN
        RETURN QUERY 
        SELECT
            S.id,
            S.SiteName,
            S.SiteHierarchicalTags,
			ST_Y(S.location::geometry) AS Latitude, 
			ST_X(S.location::geometry) AS Longitude,
            BE.DisplayName as FieldServiceCompanyName,
			BE.Id as FieldServiceCompanyId
        FROM
            site S
            INNER JOIN businessentity BE ON BE.Id = S.FieldServiceCompanyId
		WHERE
			S.EndCustomerId = BE_Id
        ORDER BY
            CASE WHEN sorting_col = 'SiteName' AND sort_type = 'ASC' THEN S.SiteName END,
            CASE WHEN sorting_col = 'SiteName' AND sort_type = 'DESC' THEN S.SiteName END DESC,
            CASE WHEN sorting_col = 'FieldServiceCompany' AND sort_type = 'ASC' THEN BE.DisplayName END,
            CASE WHEN sorting_col = 'FieldServiceCompany' AND sort_type = 'DESC' THEN BE.DisplayName END DESC
        OFFSET (page_number - 1) * page_size
        LIMIT page_size;
		
	/* If logged in user is end customer facility manager then site in which he is site admin will be returned */
    ELSIF ROLE_NAME = 'Facility Manager' THEN
        RETURN QUERY 
        SELECT
            S.id,
            S.SiteName,
            S.SiteHierarchicalTags,
			ST_Y(S.location::geometry) AS Latitude, 
			ST_X(S.location::geometry) AS Longitude,
            BE.DisplayName as FieldServiceCompanyName,
			BE.Id as FieldServiceCompanyId
        FROM
            site S
            INNER JOIN siteadmin SA ON SA.SiteId = S.Id
			INNER JOIN businessentity BE ON BE.Id = S.FieldServiceCompanyId
		WHERE
			SA.SiteAdminId = USER_Id
        ORDER BY
            CASE WHEN sorting_col = 'SiteName' AND sort_type = 'ASC' THEN S.SiteName END,
            CASE WHEN sorting_col = 'SiteName' AND sort_type = 'DESC' THEN S.SiteName END DESC,
            CASE WHEN sorting_col = 'FieldServiceCompany' AND sort_type = 'ASC' THEN BE.DisplayName END,
            CASE WHEN sorting_col = 'FieldServiceCompany' AND sort_type = 'DESC' THEN BE.DisplayName END DESC
        OFFSET (page_number - 1) * page_size
        LIMIT page_size;
		
	/* If logged in user is facility user then site in which he is mapped will be returned */
    ELSIF ROLE_NAME = 'Facility User' THEN
        RETURN QUERY 
        SELECT
            S.id,
            S.SiteName,
            S.SiteHierarchicalTags,
			ST_Y(S.location::geometry) AS Latitude, 
			ST_X(S.location::geometry) AS Longitude,
            BE.DisplayName as FieldServiceCompanyName,
			BE.Id as FieldServiceCompanyId
        FROM
            siteuser SU
            INNER JOIN site S ON S.Id = SU.SiteId
			INNER JOIN businessentity BE ON BE.Id = S.FieldServiceCompanyId
		WHERE
			SU.UserId = USER_Id
        ORDER BY
            CASE WHEN sorting_col = 'SiteName' AND sort_type = 'ASC' THEN S.SiteName END,
            CASE WHEN sorting_col = 'SiteName' AND sort_type = 'DESC' THEN S.SiteName END DESC,
            CASE WHEN sorting_col = 'FieldServiceCompany' AND sort_type = 'ASC' THEN BE.DisplayName END,
            CASE WHEN sorting_col = 'FieldServiceCompany' AND sort_type = 'DESC' THEN BE.DisplayName END DESC
        OFFSET (page_number - 1) * page_size
        LIMIT page_size;
		
	/* If logged in user is a part of fa then site in which he is mapped will be returned */
    ELSIF ROLE_NAME = 'Field Service Manager' OR ROLE_NAME = 'Field Service Technician' THEN
        RETURN QUERY 
        SELECT
            S.id,
            S.SiteName,
            S.SiteHierarchicalTags,
			ST_Y(S.location::geometry) AS Latitude, 
			ST_X(S.location::geometry) AS Longitude,
            BE.DisplayName as FieldServiceCompanyName,
			BE.Id as FieldServiceCompanyId
        FROM
            site S
            INNER JOIN businessentity BE ON BE.Id = S.FieldServiceCompanyId
		WHERE
			S.EndCustomerId = endcustomer_id AND S.FieldServiceCompanyId = BE_Id
        ORDER BY
            CASE WHEN sorting_col = 'SiteName' AND sort_type = 'ASC' THEN S.SiteName END,
            CASE WHEN sorting_col = 'SiteName' AND sort_type = 'DESC' THEN S.SiteName END DESC,
            CASE WHEN sorting_col = 'FieldServiceCompany' AND sort_type = 'ASC' THEN BE.DisplayName END,
            CASE WHEN sorting_col = 'FieldServiceCompany' AND sort_type = 'DESC' THEN BE.DisplayName END DESC
        OFFSET (page_number - 1) * page_size
        LIMIT page_size;
	
	/* Else sites for selected end customers will be returend */
    ELSE
    	RETURN QUERY 
        SELECT
            S.id,
            S.SiteName,
            S.SiteHierarchicalTags,
			ST_Y(S.location::geometry) AS Latitude, 
			ST_X(S.location::geometry) AS Longitude,
            BE.DisplayName as FieldServiceCompanyName,
			BE.Id as FieldServiceCompanyId
        FROM
            site S
            INNER JOIN businessentity BE ON BE.Id = S.FieldServiceCompanyId
		WHERE
			S.EndCustomerId = endcustomer_id
        ORDER BY
            CASE WHEN sorting_col = 'SiteName' AND sort_type = 'ASC' THEN S.SiteName END,
            CASE WHEN sorting_col = 'SiteName' AND sort_type = 'DESC' THEN S.SiteName END DESC,
            CASE WHEN sorting_col = 'FieldServiceCompany' AND sort_type = 'ASC' THEN BE.DisplayName END,
            CASE WHEN sorting_col = 'FieldServiceCompany' AND sort_type = 'DESC' THEN BE.DisplayName END DESC
        OFFSET (page_number - 1) * page_size
        LIMIT page_size;
	END IF;
END;
$$;


ALTER FUNCTION public.jci_getsites(endcutomer_id uuid, user_name character varying, page_number integer, page_size integer, sorting_col character varying, sort_type character varying) OWNER TO c550sqladmin;

--
-- Name: jci_getsitescount(uuid, character varying); Type: FUNCTION; Schema: public; Owner: c550sqladmin
--

CREATE FUNCTION public.jci_getsitescount(endcustomer_id uuid, user_name character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$

DECLARE ROLE_NAME character varying (200) ;
DECLARE BE_Id uuid;
DECLARE USER_Id int;

BEGIN
    SELECT AU.Id, AR.displayname, AU.businessentityid INTO USER_Id,ROLE_NAME, BE_Id 
	FROM appuser AU
	INNER JOIN approle AR ON AR.id = AU.approleid
	WHERE AU.username = user_name;
	
    /* If logged in user is facility corp admin, then in response all sites belogs to that end customer should come*/
    IF ROLE_NAME = 'Facility Corp Admin' THEN
        RETURN ( 
        SELECT
            COUNT(S.id)
        FROM
            site S
            INNER JOIN businessentity BE ON BE.Id = S.FieldServiceCompanyId
		WHERE
			S.EndCustomerId = BE_Id);
		
	/* If logged in user is end customer facility manager then site in which he is site admin will be returned */
    ELSIF ROLE_NAME = 'Facility Manager' THEN
        RETURN ( 
        SELECT
            COUNT(SA.SiteId)
        FROM
            siteadmin SA
            INNER JOIN site S ON S.Id = SA.SiteId
		WHERE
			SA.SiteAdminId = USER_Id);
		
	/* If logged in user is facility user then site in which he is mapped will be returned */
    ELSIF ROLE_NAME = 'Facility User' THEN
        RETURN( 
        SELECT
            COUNT(S.id)
        FROM
            siteuser SU
            INNER JOIN site S ON S.Id = SU.SiteId
		WHERE
			SU.UserId = USER_Id);
			
/* If logged in user is Field Service Manager then site in which he is mapped will be returned */
 ELSIF ROLE_NAME = 'Field Service Manager' OR ROLE_NAME = 'Field Service Technician' THEN
        RETURN(
        SELECT
            COUNT(S.id)
        FROM
            site S
            INNER JOIN businessentity BE ON BE.Id = S.FieldServiceCompanyId
		WHERE
			S.EndCustomerId = endcustomer_id AND S.FieldServiceCompanyId = BE_Id);
	
	/* Else sites for selected end customers will be returend */
    ELSE
    	RETURN 
        (SELECT
            COUNT(S.id)
        FROM
            site S
            INNER JOIN businessentity BE ON BE.Id = S.FieldServiceCompanyId
		WHERE
			S.EndCustomerId = endcustomer_id);
	END IF;
END;
$$;


ALTER FUNCTION public.jci_getsitescount(endcustomer_id uuid, user_name character varying) OWNER TO c550sqladmin;

--
-- Name: jci_getsubscriptionsbybusinessidwithpagination(uuid, integer, integer, character varying, character varying); Type: FUNCTION; Schema: public; Owner: c550sqladmin
--

CREATE FUNCTION public.jci_getsubscriptionsbybusinessidwithpagination(businessid uuid, page_number integer, page_size integer, sorting_col character varying, sort_type character varying) RETURNS TABLE(id uuid, name character varying, paymentgatewaysubscriptionid character varying, startdate timestamp without time zone, enddate timestamp without time zone, licensecount integer, metadata jsonb, createdon timestamp without time zone, updatedon timestamp without time zone, renewcount integer, renewedon timestamp without time zone, status character varying, quantity integer, subscriptioncount integer, shortcode character varying, businessentityid uuid, nextrenewaldate timestamp without time zone)
    LANGUAGE plpgsql
    AS $$
DECLARE
    query text;
BEGIN
    query := format('
        SELECT 
            id,
            name,
            paymentgatewaysubscriptionid,
            startdate,
            enddate,
            licensecount,
            metadata,
            createdon,
            updatedon,
            renewcount,
            renewedon,
            status,
            quantity,
            subscriptioncount,
            shortcode,
            businessentityid,
            CASE 
                WHEN status = ''canceled'' THEN NULL 
                ELSE enddate 
            END AS nextrenewaldate
        FROM 
            public.subscription
        WHERE 
            businessentityid = %L
        ORDER BY %I %s
        OFFSET %L LIMIT %L',
        businessid, sorting_col, sort_type, (page_number - 1) * page_size, page_size);

    RETURN QUERY EXECUTE query;
END;
$$;


ALTER FUNCTION public.jci_getsubscriptionsbybusinessidwithpagination(businessid uuid, page_number integer, page_size integer, sorting_col character varying, sort_type character varying) OWNER TO c550sqladmin;

--
-- Name: jci_getsubscriptionsbypaymentgatewaycustomeridwithpagination(character varying, integer, integer, character varying, character varying); Type: FUNCTION; Schema: public; Owner: c550sqladmin
--

CREATE FUNCTION public.jci_getsubscriptionsbypaymentgatewaycustomeridwithpagination(paymentgatewaycustomerid character varying, page_number integer, page_size integer, sorting_col character varying, sort_type character varying) RETURNS TABLE(id uuid, name character varying, paymentgatewaysubscriptionid character varying, startdate timestamp without time zone, enddate timestamp without time zone, licensecount integer, metadata jsonb, createdon timestamp without time zone, updatedon timestamp without time zone, renewcount integer, renewedon timestamp without time zone, status character varying, quantity integer, subscriptioncount integer, shortcode character varying, businessentityid uuid)
    LANGUAGE plpgsql
    AS $$
DECLARE
    query text;
BEGIN
    query := format('
        SELECT 
            id,
            name,
            paymentgatewaysubscriptionid,
            startdate,
            enddate,
            licensecount,
            metadata,
            createdon,
            updatedon,
            renewcount,
            renewedon,
            status,
            quantity,
            subscriptioncount,
            shortcode,
            businessentityid
        FROM 
            public.subscription
        WHERE 
            paymentgatewaycustomerid = %L
        ORDER BY %I %s
        OFFSET %L LIMIT %L',
        paymentgatewaycustomerid, sorting_col, sort_type, (page_number - 1) * page_size, page_size);

    RETURN QUERY EXECUTE query;
END;
$$;


ALTER FUNCTION public.jci_getsubscriptionsbypaymentgatewaycustomeridwithpagination(paymentgatewaycustomerid character varying, page_number integer, page_size integer, sorting_col character varying, sort_type character varying) OWNER TO c550sqladmin;

--
-- Name: jci_searchbusinessentities(integer, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: c550sqladmin
--

CREATE FUNCTION public.jci_searchbusinessentities(be_type_id integer, user_name character varying, secret_key character varying, filter_string character varying DEFAULT NULL::character varying) RETURNS TABLE(id uuid, displayname character varying, contactname character varying, contactemail text, contactnumber text)
    LANGUAGE plpgsql
    AS $$
DECLARE
    ROLE_NAME character varying (200);
    BE_Id uuid;
    USER_Id int;
BEGIN
  
    SELECT AU.Id, AR.displayname, AU.businessentityid 
    INTO USER_Id, ROLE_NAME, BE_Id 
    FROM appuser AU
    INNER JOIN approle AR ON AR.id = AU.approleid
    WHERE AU.username = user_name;

  
    /* If logged in user is field service company user, then we will show only end customers which are in contract with the logged in user's field service company */
    IF ROLE_NAME = 'Field Service Manager' OR ROLE_NAME = 'Field Service Technician' THEN
        IF filter_string IS NULL OR filter_string = '' THEN
            RETURN QUERY
            SELECT 
                BE.Id, 
                BE.DisplayName, 
                BE.ContactName, 
                pgp_sym_decrypt(BE.ContactEmail, secret_key) AS ContactEmail,
                pgp_sym_decrypt(BE.ContactNumber, secret_key) AS ContactNumber
            FROM 
                BusinessEntity BE 
            WHERE 
                BE.BusinessEntityTypeId = be_type_id AND
                BE.Id IN (SELECT S.endcustomerid FROM site S WHERE S.fieldservicecompanyid = BE_Id)
            ORDER BY BE.DisplayName ASC;
        ELSE
            RETURN QUERY
            SELECT 
                BE.Id, 
                BE.DisplayName, 
                BE.ContactName, 
                pgp_sym_decrypt(BE.ContactEmail, secret_key) AS ContactEmail,
                pgp_sym_decrypt(BE.ContactNumber, secret_key) AS ContactNumber
            FROM 
                BusinessEntity BE 
            WHERE 
                BE.BusinessEntityTypeId = be_type_id AND
                BE.Id IN (SELECT S.endcustomerid FROM site S WHERE S.fieldservicecompanyid = BE_Id) AND
                (LOWER(BE.DisplayName) LIKE '%' || LOWER(filter_string) || '%')
            ORDER BY BE.DisplayName ASC;
        END IF;
    ELSE
        RETURN QUERY
        SELECT 
            BE.Id,
            BE.DisplayName, 
            BE.ContactName, 
            pgp_sym_decrypt(BE.ContactEmail, secret_key) AS ContactEmail,
            pgp_sym_decrypt(BE.ContactNumber, secret_key) AS ContactNumber
        FROM 
            BusinessEntity BE 
        WHERE 
            BE.BusinessEntityTypeId = be_type_id AND
            (LOWER(BE.DisplayName) LIKE '%' || LOWER(filter_string) || '%')
        ORDER BY BE.DisplayName ASC;
    END IF;    
END;
$$;


ALTER FUNCTION public.jci_searchbusinessentities(be_type_id integer, user_name character varying, secret_key character varying, filter_string character varying) OWNER TO c550sqladmin;

--
-- Name: jci_usersbyrules(character varying, uuid, character varying, character varying, integer, integer); Type: FUNCTION; Schema: public; Owner: c550sqladmin
--

CREATE FUNCTION public.jci_usersbyrules(p_username character varying, p_businessentityid uuid, p_sortingcol character varying, p_sorttype character varying, p_pagenumber integer, p_pagesize integer) RETURNS TABLE(id integer, username character varying, displayname character varying, rolename character varying, contactnumber character varying, contactname character varying, lastloginon timestamp without time zone, isactive boolean, assetvisibility integer, businessentity character varying, businessentityname character varying, totalrows integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    DefaultRule int;
BEGIN
    -- Fetch the default rule for the user
    SELECT AR.DefaultUserVisibility INTO DefaultRule
    FROM AppRole AR
    WHERE AR.Id = (SELECT AU.AppRoleId FROM AppUser AU WHERE AU.UserName = p_UserName);

    -- All Users
    IF DefaultRule = 1 THEN
        RETURN QUERY
        WITH CTE_TotalRows AS (
            SELECT count(AU.Id) as TotalRows FROM AppUser AU
        )
        SELECT AU.Id,
               AU.UserName,
               AU.DisplayName,
               AR.DisplayName AS RoleName,
               AU.ContactNumber,
               AU.ContactName,
               AU.LastLoginOn,
               AU.IsActive,
               AU.AssetVisibility,
               BET.DisplayName as BusinessEntity,
               BE.DisplayName as BusinessEntityName,
               T.TotalRows
        FROM CTE_TotalRows T
        JOIN AppUser AU ON true
        LEFT JOIN AppRole AR ON AU.AppRoleId = AR.Id
        LEFT JOIN BusinessEntity BE ON AU.BusinessEntityId = BE.Id
        LEFT JOIN BusinessEntityType BET ON BE.BusinessEntityTypeId = BET.Id
        ORDER BY
            CASE WHEN p_SortingCol = 'UserName' AND p_SortType ='ASC' THEN AU.UserName END,
            CASE WHEN p_SortingCol = 'UserName' AND p_SortType ='DESC' THEN AU.UserName END DESC,
            CASE WHEN p_SortingCol = 'RoleName' AND p_SortType ='ASC' THEN AR.DisplayName END,
            CASE WHEN p_SortingCol = 'RoleName' AND p_SortType ='DESC' THEN AR.DisplayName END DESC,
            CASE WHEN p_SortingCol = 'DisplayName' AND p_SortType ='ASC' THEN AU.DisplayName END,
            CASE WHEN p_SortingCol = 'DisplayName' AND p_SortType ='DESC' THEN AU.DisplayName END DESC,    
            CASE WHEN p_SortingCol = 'BusinessEntity' AND p_SortType ='ASC' THEN BET.DisplayName END,
            CASE WHEN p_SortingCol = 'BusinessEntity' AND p_SortType ='DESC' THEN BET.DisplayName END DESC,
            CASE WHEN p_SortingCol = 'AssetVisibility' AND p_SortType ='ASC' THEN AU.AssetVisibility END,
            CASE WHEN p_SortingCol = 'AssetVisibility' AND p_SortType ='DESC' THEN AU.AssetVisibility END DESC,
            CASE WHEN p_SortingCol = 'IsActive' AND p_SortType ='ASC' THEN AU.IsActive END,
            CASE WHEN p_SortingCol = 'IsActive' AND p_SortType ='DESC' THEN AU.IsActive END DESC,
            CASE WHEN p_SortingCol = 'LastLoginOn' AND p_SortType ='ASC' THEN AU.LastLoginOn END,
            CASE WHEN p_SortingCol = 'LastLoginOn' AND p_SortType ='DESC' THEN AU.LastLoginOn END DESC
        OFFSET (p_PageNumber-1)*p_PageSize
        FETCH NEXT p_PageSize ROWS ONLY;
    END IF;
    
    IF DefaultRule = 2 THEN
        RETURN QUERY
        WITH CTE_TotalRows AS (
            SELECT  count(AU.Id) as TotalRows FROM AppUser AU WHERE AU.BusinessEntityId = (SELECT AUF.BusinessEntityId FROM AppUser AUF WHERE AUF.UserName = p_UserName)
        )
        SELECT AU.Id,
               AU.UserName,
               AU.DisplayName,
               AR.DisplayName AS RoleName,
               AU.ContactNumber,
               AU.ContactName,
               AU.LastLoginOn,
               AU.IsActive,
               AU.AssetVisibility,
               BET.DisplayName as BusinessEntity,
               BE.DisplayName as BusinessEntityName,
               T.TotalRows
        FROM  CTE_TotalRows T, AppUser AU
        INNER JOIN AppRole AR ON AU.AppRoleId = AR.Id
        LEFT OUTER JOIN BusinessEntity BE ON AU.BusinessEntityId = BE.Id
        LEFT OUTER JOIN BusinessEntityType BET ON BE.BusinessEntityTypeId = BET.Id 
        WHERE AU.BusinessEntityId = (Select AUFF.BusinessEntityId From AppUser AUFF Where AUFF.UserName = p_UserName)
        ORDER BY
            CASE WHEN p_SortingCol = 'UserName' AND p_SortType ='ASC' THEN AU.UserName END,
            CASE WHEN p_SortingCol = 'UserName' AND p_SortType ='DESC' THEN AU.UserName END DESC,
            CASE WHEN p_SortingCol = 'RoleName' AND p_SortType ='ASC' THEN AR.DisplayName END,
            CASE WHEN p_SortingCol = 'RoleName' AND p_SortType ='DESC' THEN AR.DisplayName END DESC,
            CASE WHEN p_SortingCol = 'DisplayName' AND p_SortType ='ASC' THEN AU.DisplayName END,
            CASE WHEN p_SortingCol = 'DisplayName' AND p_SortType ='DESC' THEN AU.DisplayName END DESC,    
            CASE WHEN p_SortingCol = 'BusinessEntity' AND p_SortType ='ASC' THEN BET.DisplayName END,
            CASE WHEN p_SortingCol = 'BusinessEntity' AND p_SortType ='DESC' THEN BET.DisplayName END DESC,
            CASE WHEN p_SortingCol = 'AssetVisibility' AND p_SortType ='ASC' THEN AU.AssetVisibility END,
            CASE WHEN p_SortingCol = 'AssetVisibility' AND p_SortType ='DESC' THEN AU.AssetVisibility END DESC,
            CASE WHEN p_SortingCol = 'IsActive' AND p_SortType ='ASC' THEN AU.IsActive END,
            CASE WHEN p_SortingCol = 'IsActive' AND p_SortType ='DESC' THEN AU.IsActive END DESC,
            CASE WHEN p_SortingCol = 'LastLoginOn' AND p_SortType ='ASC' THEN AU.LastLoginOn END,
            CASE WHEN p_SortingCol = 'LastLoginOn' AND p_SortType ='DESC' THEN AU.LastLoginOn END DESC
        OFFSET (p_PageNumber-1)*p_PageSize
        FETCH NEXT p_PageSize ROWS ONLY;
    END IF;
	
	IF DefaultRule = 3 THEN
		RETURN QUERY
		WITH CTE_TotalRows AS (
			SELECT  count(AU.Id) as TotalRows FROM AppUser AU WHERE AU.BusinessEntityId IN (SELECT BEF.Id from BusinessEntity BEF WHERE BEF.BusinessEntityTypeId = (SELECT BETF.id from BusinessEntityType BETF WHERE BETF.AssetTagKey= 'endCustomer'))
		)
		SELECT AU.Id,
			   AU.UserName,
			   AU.DisplayName,
			   AR.DisplayName AS RoleName,
			   AU.ContactNumber,
			   AU.ContactName,
			   AU.LastLoginOn,
			   AU.IsActive,
			   AU.AssetVisibility,
			   BET.DisplayName as BusinessEntity,
			   BE.DisplayName as BusinessEntityName,
			   T.TotalRows
		FROM  CTE_TotalRows T, AppUser AU
		INNER JOIN AppRole AR ON AU.AppRoleId = AR.Id
		LEFT OUTER JOIN BusinessEntity BE ON AU.BusinessEntityId = BE.Id
		LEFT OUTER JOIN BusinessEntityType BET ON BE.BusinessEntityTypeId = BET.Id 
		WHERE AU.BusinessEntityId IN (SELECT BEFF.Id from BusinessEntity BEFF WHERE BEFF.BusinessEntityTypeId = (SELECT BETFF.id from BusinessEntityType BETFF WHERE BETFF.AssetTagKey= 'endCustomer'))
		ORDER BY
			CASE WHEN @SortingCol = 'UserName' AND @SortType ='ASC' THEN UserName END ,
			CASE WHEN @SortingCol = 'UserName' AND @SortType ='DESC' THEN UserName END DESC,
			CASE WHEN @SortingCol = 'RoleName' AND @SortType ='ASC' THEN AR.DisplayName END ,
			CASE WHEN @SortingCol = 'RoleName' AND @SortType ='DESC' THEN AR.DisplayName END DESC,
			CASE WHEN @SortingCol = 'DisplayName' AND @SortType ='ASC' THEN AU.DisplayName END ,
			CASE WHEN @SortingCol = 'DisplayName' AND @SortType ='DESC' THEN AU.DisplayName END DESC,    
			CASE WHEN @SortingCol = 'BusinessEntity' AND @SortType ='ASC' THEN BET.DisplayName END ,
			CASE WHEN @SortingCol = 'BusinessEntity' AND @SortType ='DESC' THEN BET.DisplayName END DESC,
			CASE WHEN @SortingCol = 'AssetVisibility' AND @SortType ='ASC' THEN AU.AssetVisibility END ,
			CASE WHEN @SortingCol = 'AssetVisibility' AND @SortType ='DESC' THEN AU.AssetVisibility END DESC,
			CASE WHEN @SortingCol = 'IsActive' AND @SortType ='ASC' THEN AU.IsActive END ,
			CASE WHEN @SortingCol = 'IsActive' AND @SortType ='DESC' THEN AU.IsActive END DESC,
			CASE WHEN @SortingCol = 'LastLoginOn' AND @SortType ='ASC' THEN AU.LastLoginOn END ,
			CASE WHEN @SortingCol = 'LastLoginOn' AND @SortType ='DESC' THEN AU.LastLoginOn END DESC
		OFFSET (p_PageNumber-1)*p_PageSize
        FETCH NEXT p_PageSize ROWS ONLY;
    END IF;
	
	IF DefaultRule = 4 THEN
		RETURN QUERY
		WITH CTE_TotalRows AS (
			Select COUNT(T.Id) as TotalRows from 
				(SELECT AU.Id FROM AppUser AU WHERE AU.BusinessEntityId IN (SELECT BE.Id from BusinessEntity BE WHERE BE.BusinessEntityTypeId = (SELECT BET.Id from BusinessEntityType WHERE BET.AssetTagKey= 'endCustomer')) AND AU.CreatedByBusinessEntityId = (Select AU.BusinessEntityId From AppUser AU Where AU.UserName = p_UserName)) T
		)
		Select * from (
					SELECT AU.Id,
					AU.UserName as Username,
					AU.DisplayName,
					AR.DisplayName AS RoleName,
					AU.ContactNumber,
					AU.ContactName,
					AU.LastLoginOn,
					AU.IsActive,
					AU.AssetVisibility,
					BET.DisplayName as BusinessEntity,
                    BE.DisplayName as BusinessEntityName,
					T.TotalRows
		FROM  CTE_TotalRows T, AppUser AU
		INNER JOIN AppRole AR ON AU.AppRoleId = AR.Id
		LEFT OUTER JOIN BusinessEntity BE ON AU.BusinessEntityId = BE.Id
		LEFT OUTER JOIN BusinessEntityType BET ON BE.BusinessEntityTypeId = BET.Id
		WHERE
		AU.BusinessEntityId IN
		(SELECT BEF.Id from BusinessEntity BEF WHERE BEF.BusinessEntityTypeId =
		(SELECT BETF.Id from BETF.BusinessEntityType WHERE BETF.AssetTagKey= 'endCustomer')) AND
		AU.CreatedByBusinessEntityId = (Select AUF.BusinessEntityId From AppUser AUF Where AUF.UserName = p_UserName)) T
		ORDER BY
			CASE WHEN p_SortingCol = 'UserName' AND p_SortType ='ASC' THEN T.UserName END ,
        	CASE WHEN p_SortingCol = 'UserName' AND p_SortType ='DESC' THEN T.UserName END DESC,
        	CASE WHEN p_SortingCol = 'RoleName' AND p_SortType ='ASC' THEN T.RoleName END ,
        	CASE WHEN p_SortingCol = 'RoleName' AND p_SortType ='DESC' THEN T.RoleName END DESC,
        	CASE WHEN p_SortingCol = 'DisplayName' AND p_SortType ='ASC' THEN T.DisplayName END ,
        	CASE WHEN p_SortingCol = 'DisplayName' AND p_SortType ='DESC' THEN T.DisplayName END DESC,    
        	CASE WHEN p_SortingCol = 'BusinessEntity' AND p_SortType ='ASC' THEN T.DisplayName END ,
        	CASE WHEN p_SortingCol = 'BusinessEntity' AND p_SortType ='DESC' THEN T.DisplayName END DESC,
        	CASE WHEN p_SortingCol = 'IsActive' AND p_SortType ='ASC' THEN T.IsActive END ,
        	CASE WHEN p_SortingCol = 'IsActive' AND p_SortType ='DESC' THEN T.IsActive END DESC,
        	CASE WHEN p_SortingCol = 'LastLoginOn' AND p_SortType ='ASC' THEN T.LastLoginOn END ,
        	CASE WHEN p_SortingCol = 'LastLoginOn' AND p_SortType ='DESC' THEN T.LastLoginOn END DESC
		OFFSET (p_PageNumber-1)*@PageSize
        FETCH NEXT p_PageSize ROWS ONLY;
	END IF;
	
	IF DefaultRule = 5 THEN
		RETURN QUERY
		WITH CTE_TotalRows AS (
			Select COUNT(T.Id) as TotalRows from 
							(SELECT AU.Id FROM AppUser AU WHERE AU.BusinessEntityId IN (SELECT BE.Id from BusinessEntity BE WHERE BE.BusinessEntityTypeId = (SELECT BET.Id from BusinessEntityType BET WHERE BET.AssetTagKey= 'endCustomer')) 
							UNION SELECT AU.Id FROM AppUser AU WHERE AU.BusinessEntityId = (SELECT AUF.BusinessEntityId FROM AppUser AUF WHERE AUF.UserName = p_UserName)) T
		)
		Select * from 
					(SELECT AU.Id,
					AU.UserName as Username,
					AU.DisplayName,
					AR.DisplayName AS RoleName,
					AU.ContactNumber,
					AU.ContactName,
					AU.LastLoginOn,
					AU.IsActive,
					AU.AssetVisibility,
					BET.DisplayName as BusinessEntity,
                    BE.DisplayName as BusinessEntityName,
					T.TotalRows
		FROM  CTE_TotalRows T, AppUser AU
		INNER JOIN AppRole AR ON AU.AppRoleId = AR.Id
		LEFT OUTER JOIN BusinessEntity BE ON AU.BusinessEntityId = BE.Id
		LEFT OUTER JOIN BusinessEntityType BET ON BE.BusinessEntityTypeId = BET.Id 
		WHERE
			AU.BusinessEntityId IN
			(SELECT Id from BusinessEntity WHERE BusinessEntityTypeId =
			(SELECT Id from BusinessEntityType WHERE AssetTagKey= 'endCustomer'))
			UNION
			SELECT AU.Id,
			AU.UserName as Username,
			AU.DisplayName,
			AR.DisplayName AS RoleName,
			AU.ContactNumber,
			AU.ContactName,
			AU.LastLoginOn,
			AU.IsActive,
			AU.AssetVisibility,
			BET.DisplayName as BusinessEntity,
            BE.DisplayName as BusinessEntityName,
			TR.TotalRows
			FROM  CTE_TotalRows TR, AppUser AU
            INNER JOIN AppRole AR ON AU.AppRoleId = AR.Id
			LEFT OUTER JOIN BusinessEntity BE ON AU.BusinessEntityId = BE.Id
			LEFT OUTER JOIN BusinessEntityType BET ON BE.BusinessEntityTypeId = BET.Id 
		    WHERE AU.BusinessEntityId = (SELECT AUFF.BusinessEntityId FROM AppUser AUFF WHERE AUFF.UserName = p_UserName)) T
		ORDER BY
			CASE WHEN p_SortingCol = 'UserName' AND p_SortType ='ASC' THEN T.UserName END ,
            CASE WHEN p_SortingCol = 'UserName' AND p_SortType ='DESC' THEN T.UserName END DESC,
            CASE WHEN p_SortingCol = 'RoleName' AND p_SortType ='ASC' THEN T.RoleName END ,
            CASE WHEN p_SortingCol = 'RoleName' AND p_SortType ='DESC' THEN T.RoleName END DESC,
            CASE WHEN p_SortingCol = 'DisplayName' AND p_SortType ='ASC' THEN T.DisplayName END ,
            CASE WHEN p_SortingCol = 'DisplayName' AND p_SortType ='DESC' THEN T.DisplayName END DESC,    
            CASE WHEN p_SortingCol = 'BusinessEntity' AND p_SortType ='ASC' THEN T.DisplayName END ,
            CASE WHEN p_SortingCol = 'BusinessEntity' AND p_SortType ='DESC' THEN T.DisplayName END DESC,
            CASE WHEN p_SortingCol = 'IsActive' AND p_SortType ='ASC' THEN T.IsActive END ,
            CASE WHEN p_SortingCol = 'IsActive' AND p_SortType ='DESC' THEN T.IsActive END DESC,
            CASE WHEN p_SortingCol = 'LastLoginOn' AND p_SortType ='ASC' THEN T.LastLoginOn END ,
            CASE WHEN p_SortingCol = 'LastLoginOn' AND p_SortType ='DESC' THEN T.LastLoginOn END DESC
		OFFSET (p_PageNumber-1)*@PageSize
        FETCH NEXT p_PageSize ROWS ONLY;
	END IF;
	
	IF DefaultRule = 6 THEN
		RETURN QUERY
		WITH CTE_TotalRows AS(
			Select COUNT(T.Id) as TotalRows from 
							(SELECT AU.Id FROM AppUser AU WHERE AU.BusinessEntityId IN (SELECT BE.Id from BE.BusinessEntity WHERE BE.BusinessEntityTypeId = (SELECT BET.Id from BusinessEntityType WHERE BET.AssetTagKey= 'endCustomer')) AND AU.CreatedByBusinessEntityId = (Select AU.BusinessEntityId From AppUser AU Where AU.UserName = p_UserName) 
							UNION SELECT AU.Id FROM AppUser AU WHERE AU.BusinessEntityId = (SELECT AUF.BusinessEntityId FROM AppUser AUF WHERE AUF.UserName = p_UserName)) T
		)
		Select * from 
					(SELECT AU.Id,
					AU.UserName as Username,
					AU.DisplayName,
					AR.DisplayName AS RoleName,
					AU.ContactNumber,
					AU.ContactName,
					AU.LastLoginOn,
					AU.IsActive,
					AU.AssetVisibility,
					BET.DisplayName as BusinessEntity,
                    BE.DisplayName as BusinessEntityName,
					T.TotalRows
					FROM CTE_TotalRows T, AppUser AU
                        INNER JOIN AppRole AR ON AU.AppRoleId = AR.Id
						LEFT OUTER JOIN BusinessEntity BE ON AU.BusinessEntityId = BE.Id
						LEFT OUTER JOIN BusinessEntityType BET ON BE.BusinessEntityTypeId = BET.Id 
						WHERE
						AU.BusinessEntityId IN
						(SELECT BEF.Id from BusinessEntity BEF WHERE BEF.BusinessEntityTypeId =
						(SELECT BETF.Id from BusinessEntityType BETF WHERE BETF.AssetTagKey= 'endCustomer')) AND AU.CreatedByBusinessEntityId = (Select AUF.BusinessEntityId From AppUser Where AUF.UserName = p_UserName)
						UNION
					 SELECT AU.Id,
							AU.UserName as Username,
							AU.DisplayName,
							AR.DisplayName AS RoleName,
							AU.ContactNumber,
							AU.ContactName,
							AU.LastLoginOn,
							AU.IsActive,
							AU.AssetVisibility,
							BET.DisplayName as BusinessEntity,
                            BE.DisplayName as BusinessEntityName,
							TR.TotalRows
					 		FROM  CTE_TotalRows TR, AppUser AU
                            INNER JOIN AppRole AR ON AU.AppRoleId = AR.Id
							LEFT OUTER JOIN BusinessEntity BE ON AU.BusinessEntityId = BE.Id
							LEFT OUTER JOIN BusinessEntityType BET ON BE.BusinessEntityTypeId = BET.Id 
							WHERE AU.BusinessEntityId = (SELECT AUFF.BusinessEntityId FROM AUFF.AppUser WHERE AUFF.UserName = p_UserName)) T
							ORDER BY
							CASE WHEN p_SortingCol = 'UserName' AND p_SortType ='ASC' THEN T.UserName END ,
                            CASE WHEN p_SortingCol = 'UserName' AND p_SortType ='DESC' THEN T.UserName END DESC,
                            CASE WHEN p_SortingCol = 'RoleName' AND p_SortType ='ASC' THEN T.RoleName END ,
                            CASE WHEN p_SortingCol = 'RoleName' AND p_SortType ='DESC' THEN T.RoleName END DESC,
                            CASE WHEN p_SortingCol = 'DisplayName' AND p_SortType ='ASC' THEN T.DisplayName END ,
                            CASE WHEN p_SortingCol = 'DisplayName' AND p_SortType ='DESC' THEN T.DisplayName END DESC,    
                            CASE WHEN p_SortingCol = 'BusinessEntity' AND p_SortType ='ASC' THEN T.DisplayName END ,
                            CASE WHEN p_SortingCol = 'BusinessEntity' AND p_SortType ='DESC' THEN T.DisplayName END DESC,
                            CASE WHEN p_SortingCol = 'IsActive' AND p_SortType ='ASC' THEN T.IsActive END ,
                            CASE WHEN p_SortingCol = 'IsActive' AND p_SortType ='DESC' THEN T.IsActive END DESC,
                            CASE WHEN p_SortingCol = 'LastLoginOn' AND p_SortType ='ASC' THEN T.LastLoginOn END ,
                            CASE WHEN p_SortingCol = 'LastLoginOn' AND p_SortType ='DESC' THEN T.LastLoginOn END DESC
						OFFSET (p_PageNumber-1)*@PageSize
                        FETCH NEXT p_PageSize ROWS ONLY;
			END IF;
END;
$$;


ALTER FUNCTION public.jci_usersbyrules(p_username character varying, p_businessentityid uuid, p_sortingcol character varying, p_sorttype character varying, p_pagenumber integer, p_pagesize integer) OWNER TO c550sqladmin;

--
-- Name: usersbyrules(character varying, uuid, character varying, character varying, integer, integer); Type: FUNCTION; Schema: public; Owner: c550sqladmin
--

CREATE FUNCTION public.usersbyrules(p_username character varying, p_businessentityid uuid, p_sortingcol character varying, p_sorttype character varying, p_pagenumber integer, p_pagesize integer) RETURNS TABLE(id integer, username character varying, displayname character varying, rolename character varying, contactnumber character varying, contactname character varying, lastloginon timestamp without time zone, isactive boolean, assetvisibility integer, businessentity character varying, businessentityname character varying, totalrows integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    DefaultRule int;
BEGIN
    -- Fetch the default rule for the user
    SELECT AR.DefaultUserVisibility INTO DefaultRule
    FROM AppRole AR
    WHERE AR.Id = (SELECT AU.AppRoleId FROM AppUser AU WHERE AU.UserName = p_UserName);

    -- All Users
    IF DefaultRule = 1 THEN
        RETURN QUERY
        WITH CTE_TotalRows AS (
            SELECT count(AU.Id) as TotalRows FROM AppUser AU
        )
        SELECT AU.Id,
               AU.UserName,
               AU.DisplayName,
               AR.DisplayName AS RoleName,
               AU.ContactNumber,
               AU.ContactName,
               AU.LastLoginOn,
               AU.IsActive,
               AU.AssetVisibility,
               BET.DisplayName as BusinessEntity,
               BE.DisplayName as BusinessEntityName,
               T.TotalRows
        FROM CTE_TotalRows T
        JOIN AppUser AU ON true
        LEFT JOIN AppRole AR ON AU.AppRoleId = AR.Id
        LEFT JOIN BusinessEntity BE ON AU.BusinessEntityId = BE.Id
        LEFT JOIN BusinessEntityType BET ON BE.BusinessEntityTypeId = BET.Id
        ORDER BY
            CASE WHEN p_SortingCol = 'UserName' AND p_SortType ='ASC' THEN AU.UserName END,
            CASE WHEN p_SortingCol = 'UserName' AND p_SortType ='DESC' THEN AU.UserName END DESC,
            CASE WHEN p_SortingCol = 'RoleName' AND p_SortType ='ASC' THEN AR.DisplayName END,
            CASE WHEN p_SortingCol = 'RoleName' AND p_SortType ='DESC' THEN AR.DisplayName END DESC,
            CASE WHEN p_SortingCol = 'DisplayName' AND p_SortType ='ASC' THEN AU.DisplayName END,
            CASE WHEN p_SortingCol = 'DisplayName' AND p_SortType ='DESC' THEN AU.DisplayName END DESC,    
            CASE WHEN p_SortingCol = 'BusinessEntity' AND p_SortType ='ASC' THEN BET.DisplayName END,
            CASE WHEN p_SortingCol = 'BusinessEntity' AND p_SortType ='DESC' THEN BET.DisplayName END DESC,
            CASE WHEN p_SortingCol = 'AssetVisibility' AND p_SortType ='ASC' THEN AU.AssetVisibility END,
            CASE WHEN p_SortingCol = 'AssetVisibility' AND p_SortType ='DESC' THEN AU.AssetVisibility END DESC,
            CASE WHEN p_SortingCol = 'IsActive' AND p_SortType ='ASC' THEN AU.IsActive END,
            CASE WHEN p_SortingCol = 'IsActive' AND p_SortType ='DESC' THEN AU.IsActive END DESC,
            CASE WHEN p_SortingCol = 'LastLoginOn' AND p_SortType ='ASC' THEN AU.LastLoginOn END,
            CASE WHEN p_SortingCol = 'LastLoginOn' AND p_SortType ='DESC' THEN AU.LastLoginOn END DESC
        OFFSET (p_PageNumber-1)*p_PageSize
        FETCH NEXT p_PageSize ROWS ONLY;
    END IF;
    
    IF DefaultRule = 2 THEN
        RETURN QUERY
        WITH CTE_TotalRows AS (
            SELECT  count(AU.Id) as TotalRows FROM AppUser AU WHERE AU.BusinessEntityId = (SELECT AUF.BusinessEntityId FROM AppUser AUF WHERE AUF.UserName = p_UserName)
        )
        SELECT AU.Id,
               AU.UserName,
               AU.DisplayName,
               AR.DisplayName AS RoleName,
               AU.ContactNumber,
               AU.ContactName,
               AU.LastLoginOn,
               AU.IsActive,
               AU.AssetVisibility,
               BET.DisplayName as BusinessEntity,
               BE.DisplayName as BusinessEntityName,
               T.TotalRows
        FROM  CTE_TotalRows T, AppUser AU
        INNER JOIN AppRole AR ON AU.AppRoleId = AR.Id
        LEFT OUTER JOIN BusinessEntity BE ON AU.BusinessEntityId = BE.Id
        LEFT OUTER JOIN BusinessEntityType BET ON BE.BusinessEntityTypeId = BET.Id 
        WHERE AU.BusinessEntityId = (Select AUFF.BusinessEntityId From AppUser AUFF Where AUFF.UserName = p_UserName)
        ORDER BY
            CASE WHEN p_SortingCol = 'UserName' AND p_SortType ='ASC' THEN AU.UserName END,
            CASE WHEN p_SortingCol = 'UserName' AND p_SortType ='DESC' THEN AU.UserName END DESC,
            CASE WHEN p_SortingCol = 'RoleName' AND p_SortType ='ASC' THEN AR.DisplayName END,
            CASE WHEN p_SortingCol = 'RoleName' AND p_SortType ='DESC' THEN AR.DisplayName END DESC,
            CASE WHEN p_SortingCol = 'DisplayName' AND p_SortType ='ASC' THEN AU.DisplayName END,
            CASE WHEN p_SortingCol = 'DisplayName' AND p_SortType ='DESC' THEN AU.DisplayName END DESC,    
            CASE WHEN p_SortingCol = 'BusinessEntity' AND p_SortType ='ASC' THEN BET.DisplayName END,
            CASE WHEN p_SortingCol = 'BusinessEntity' AND p_SortType ='DESC' THEN BET.DisplayName END DESC,
            CASE WHEN p_SortingCol = 'AssetVisibility' AND p_SortType ='ASC' THEN AU.AssetVisibility END,
            CASE WHEN p_SortingCol = 'AssetVisibility' AND p_SortType ='DESC' THEN AU.AssetVisibility END DESC,
            CASE WHEN p_SortingCol = 'IsActive' AND p_SortType ='ASC' THEN AU.IsActive END,
            CASE WHEN p_SortingCol = 'IsActive' AND p_SortType ='DESC' THEN AU.IsActive END DESC,
            CASE WHEN p_SortingCol = 'LastLoginOn' AND p_SortType ='ASC' THEN AU.LastLoginOn END,
            CASE WHEN p_SortingCol = 'LastLoginOn' AND p_SortType ='DESC' THEN AU.LastLoginOn END DESC
        OFFSET (p_PageNumber-1)*p_PageSize
        FETCH NEXT p_PageSize ROWS ONLY;
    END IF;
	
	IF DefaultRule = 3 THEN
		RETURN QUERY
		WITH CTE_TotalRows AS (
			SELECT  count(AU.Id) as TotalRows FROM AppUser AU WHERE AU.BusinessEntityId IN (SELECT BEF.Id from BusinessEntity BEF WHERE BEF.BusinessEntityTypeId = (SELECT BETF.id from BusinessEntityType BETF WHERE BETF.AssetTagKey= 'endCustomer'))
		)
		SELECT AU.Id,
			   AU.UserName,
			   AU.DisplayName,
			   AR.DisplayName AS RoleName,
			   AU.ContactNumber,
			   AU.ContactName,
			   AU.LastLoginOn,
			   AU.IsActive,
			   AU.AssetVisibility,
			   BET.DisplayName as BusinessEntity,
			   BE.DisplayName as BusinessEntityName,
			   T.TotalRows
		FROM  CTE_TotalRows T, AppUser AU
		INNER JOIN AppRole AR ON AU.AppRoleId = AR.Id
		LEFT OUTER JOIN BusinessEntity BE ON AU.BusinessEntityId = BE.Id
		LEFT OUTER JOIN BusinessEntityType BET ON BE.BusinessEntityTypeId = BET.Id 
		WHERE AU.BusinessEntityId IN (SELECT BEFF.Id from BusinessEntity BEFF WHERE BEFF.BusinessEntityTypeId = (SELECT BETFF.id from BusinessEntityType BETFF WHERE BETFF.AssetTagKey= 'endCustomer'))
		ORDER BY
			CASE WHEN @SortingCol = 'UserName' AND @SortType ='ASC' THEN UserName END ,
			CASE WHEN @SortingCol = 'UserName' AND @SortType ='DESC' THEN UserName END DESC,
			CASE WHEN @SortingCol = 'RoleName' AND @SortType ='ASC' THEN AR.DisplayName END ,
			CASE WHEN @SortingCol = 'RoleName' AND @SortType ='DESC' THEN AR.DisplayName END DESC,
			CASE WHEN @SortingCol = 'DisplayName' AND @SortType ='ASC' THEN AU.DisplayName END ,
			CASE WHEN @SortingCol = 'DisplayName' AND @SortType ='DESC' THEN AU.DisplayName END DESC,    
			CASE WHEN @SortingCol = 'BusinessEntity' AND @SortType ='ASC' THEN BET.DisplayName END ,
			CASE WHEN @SortingCol = 'BusinessEntity' AND @SortType ='DESC' THEN BET.DisplayName END DESC,
			CASE WHEN @SortingCol = 'AssetVisibility' AND @SortType ='ASC' THEN AU.AssetVisibility END ,
			CASE WHEN @SortingCol = 'AssetVisibility' AND @SortType ='DESC' THEN AU.AssetVisibility END DESC,
			CASE WHEN @SortingCol = 'IsActive' AND @SortType ='ASC' THEN AU.IsActive END ,
			CASE WHEN @SortingCol = 'IsActive' AND @SortType ='DESC' THEN AU.IsActive END DESC,
			CASE WHEN @SortingCol = 'LastLoginOn' AND @SortType ='ASC' THEN AU.LastLoginOn END ,
			CASE WHEN @SortingCol = 'LastLoginOn' AND @SortType ='DESC' THEN AU.LastLoginOn END DESC
		OFFSET (p_PageNumber-1)*p_PageSize
        FETCH NEXT p_PageSize ROWS ONLY;
    END IF;
	
	IF DefaultRule = 4 THEN
		RETURN QUERY
		WITH CTE_TotalRows AS (
			Select COUNT(T.Id) as TotalRows from 
				(SELECT AU.Id FROM AppUser AU WHERE AU.BusinessEntityId IN (SELECT BE.Id from BusinessEntity BE WHERE BE.BusinessEntityTypeId = (SELECT BET.Id from BusinessEntityType WHERE BET.AssetTagKey= 'endCustomer')) AND AU.CreatedByBusinessEntityId = (Select AU.BusinessEntityId From AppUser AU Where AU.UserName = p_UserName)) T
		)
		Select * from (
					SELECT AU.Id,
					AU.UserName as Username,
					AU.DisplayName,
					AR.DisplayName AS RoleName,
					AU.ContactNumber,
					AU.ContactName,
					AU.LastLoginOn,
					AU.IsActive,
					AU.AssetVisibility,
					BET.DisplayName as BusinessEntity,
                    BE.DisplayName as BusinessEntityName,
					T.TotalRows
		FROM  CTE_TotalRows T, AppUser AU
		INNER JOIN AppRole AR ON AU.AppRoleId = AR.Id
		LEFT OUTER JOIN BusinessEntity BE ON AU.BusinessEntityId = BE.Id
		LEFT OUTER JOIN BusinessEntityType BET ON BE.BusinessEntityTypeId = BET.Id
		WHERE
		AU.BusinessEntityId IN
		(SELECT BEF.Id from BusinessEntity BEF WHERE BEF.BusinessEntityTypeId =
		(SELECT BETF.Id from BETF.BusinessEntityType WHERE BETF.AssetTagKey= 'endCustomer')) AND
		AU.CreatedByBusinessEntityId = (Select AUF.BusinessEntityId From AppUser AUF Where AUF.UserName = p_UserName)) T
		ORDER BY
			CASE WHEN p_SortingCol = 'UserName' AND p_SortType ='ASC' THEN T.UserName END ,
        	CASE WHEN p_SortingCol = 'UserName' AND p_SortType ='DESC' THEN T.UserName END DESC,
        	CASE WHEN p_SortingCol = 'RoleName' AND p_SortType ='ASC' THEN T.RoleName END ,
        	CASE WHEN p_SortingCol = 'RoleName' AND p_SortType ='DESC' THEN T.RoleName END DESC,
        	CASE WHEN p_SortingCol = 'DisplayName' AND p_SortType ='ASC' THEN T.DisplayName END ,
        	CASE WHEN p_SortingCol = 'DisplayName' AND p_SortType ='DESC' THEN T.DisplayName END DESC,    
        	CASE WHEN p_SortingCol = 'BusinessEntity' AND p_SortType ='ASC' THEN T.DisplayName END ,
        	CASE WHEN p_SortingCol = 'BusinessEntity' AND p_SortType ='DESC' THEN T.DisplayName END DESC,
        	CASE WHEN p_SortingCol = 'IsActive' AND p_SortType ='ASC' THEN T.IsActive END ,
        	CASE WHEN p_SortingCol = 'IsActive' AND p_SortType ='DESC' THEN T.IsActive END DESC,
        	CASE WHEN p_SortingCol = 'LastLoginOn' AND p_SortType ='ASC' THEN T.LastLoginOn END ,
        	CASE WHEN p_SortingCol = 'LastLoginOn' AND p_SortType ='DESC' THEN T.LastLoginOn END DESC
		OFFSET (p_PageNumber-1)*@PageSize
        FETCH NEXT p_PageSize ROWS ONLY;
	END IF;
	
	IF DefaultRule = 5 THEN
		RETURN QUERY
		WITH CTE_TotalRows AS (
			Select COUNT(T.Id) as TotalRows from 
							(SELECT AU.Id FROM AppUser AU WHERE AU.BusinessEntityId IN (SELECT BE.Id from BusinessEntity BE WHERE BE.BusinessEntityTypeId = (SELECT BET.Id from BusinessEntityType BET WHERE BET.AssetTagKey= 'endCustomer')) 
							UNION SELECT AU.Id FROM AppUser AU WHERE AU.BusinessEntityId = (SELECT AUF.BusinessEntityId FROM AppUser AUF WHERE AUF.UserName = p_UserName)) T
		)
		Select * from 
					(SELECT AU.Id,
					AU.UserName as Username,
					AU.DisplayName,
					AR.DisplayName AS RoleName,
					AU.ContactNumber,
					AU.ContactName,
					AU.LastLoginOn,
					AU.IsActive,
					AU.AssetVisibility,
					BET.DisplayName as BusinessEntity,
                    BE.DisplayName as BusinessEntityName,
					T.TotalRows
		FROM  CTE_TotalRows T, AppUser AU
		INNER JOIN AppRole AR ON AU.AppRoleId = AR.Id
		LEFT OUTER JOIN BusinessEntity BE ON AU.BusinessEntityId = BE.Id
		LEFT OUTER JOIN BusinessEntityType BET ON BE.BusinessEntityTypeId = BET.Id 
		WHERE
			AU.BusinessEntityId IN
			(SELECT Id from BusinessEntity WHERE BusinessEntityTypeId =
			(SELECT Id from BusinessEntityType WHERE AssetTagKey= 'endCustomer'))
			UNION
			SELECT AU.Id,
			AU.UserName as Username,
			AU.DisplayName,
			AR.DisplayName AS RoleName,
			AU.ContactNumber,
			AU.ContactName,
			AU.LastLoginOn,
			AU.IsActive,
			AU.AssetVisibility,
			BET.DisplayName as BusinessEntity,
            BE.DisplayName as BusinessEntityName,
			TR.TotalRows
			FROM  CTE_TotalRows TR, AppUser AU
            INNER JOIN AppRole AR ON AU.AppRoleId = AR.Id
			LEFT OUTER JOIN BusinessEntity BE ON AU.BusinessEntityId = BE.Id
			LEFT OUTER JOIN BusinessEntityType BET ON BE.BusinessEntityTypeId = BET.Id 
		    WHERE AU.BusinessEntityId = (SELECT AUFF.BusinessEntityId FROM AppUser AUFF WHERE AUFF.UserName = p_UserName)) T
		ORDER BY
			CASE WHEN p_SortingCol = 'UserName' AND p_SortType ='ASC' THEN T.UserName END ,
            CASE WHEN p_SortingCol = 'UserName' AND p_SortType ='DESC' THEN T.UserName END DESC,
            CASE WHEN p_SortingCol = 'RoleName' AND p_SortType ='ASC' THEN T.RoleName END ,
            CASE WHEN p_SortingCol = 'RoleName' AND p_SortType ='DESC' THEN T.RoleName END DESC,
            CASE WHEN p_SortingCol = 'DisplayName' AND p_SortType ='ASC' THEN T.DisplayName END ,
            CASE WHEN p_SortingCol = 'DisplayName' AND p_SortType ='DESC' THEN T.DisplayName END DESC,    
            CASE WHEN p_SortingCol = 'BusinessEntity' AND p_SortType ='ASC' THEN T.DisplayName END ,
            CASE WHEN p_SortingCol = 'BusinessEntity' AND p_SortType ='DESC' THEN T.DisplayName END DESC,
            CASE WHEN p_SortingCol = 'IsActive' AND p_SortType ='ASC' THEN T.IsActive END ,
            CASE WHEN p_SortingCol = 'IsActive' AND p_SortType ='DESC' THEN T.IsActive END DESC,
            CASE WHEN p_SortingCol = 'LastLoginOn' AND p_SortType ='ASC' THEN T.LastLoginOn END ,
            CASE WHEN p_SortingCol = 'LastLoginOn' AND p_SortType ='DESC' THEN T.LastLoginOn END DESC
		OFFSET (p_PageNumber-1)*@PageSize
        FETCH NEXT p_PageSize ROWS ONLY;
	END IF;
	
	IF DefaultRule = 6 THEN
		RETURN QUERY
		WITH CTE_TotalRows AS(
			Select COUNT(T.Id) as TotalRows from 
							(SELECT AU.Id FROM AppUser AU WHERE AU.BusinessEntityId IN (SELECT BE.Id from BE.BusinessEntity WHERE BE.BusinessEntityTypeId = (SELECT BET.Id from BusinessEntityType WHERE BET.AssetTagKey= 'endCustomer')) AND AU.CreatedByBusinessEntityId = (Select AU.BusinessEntityId From AppUser AU Where AU.UserName = p_UserName) 
							UNION SELECT AU.Id FROM AppUser AU WHERE AU.BusinessEntityId = (SELECT AUF.BusinessEntityId FROM AppUser AUF WHERE AUF.UserName = p_UserName)) T
		)
		Select * from 
					(SELECT AU.Id,
					AU.UserName as Username,
					AU.DisplayName,
					AR.DisplayName AS RoleName,
					AU.ContactNumber,
					AU.ContactName,
					AU.LastLoginOn,
					AU.IsActive,
					AU.AssetVisibility,
					BET.DisplayName as BusinessEntity,
                    BE.DisplayName as BusinessEntityName,
					T.TotalRows
					FROM CTE_TotalRows T, AppUser AU
                        INNER JOIN AppRole AR ON AU.AppRoleId = AR.Id
						LEFT OUTER JOIN BusinessEntity BE ON AU.BusinessEntityId = BE.Id
						LEFT OUTER JOIN BusinessEntityType BET ON BE.BusinessEntityTypeId = BET.Id 
						WHERE
						AU.BusinessEntityId IN
						(SELECT BEF.Id from BusinessEntity BEF WHERE BEF.BusinessEntityTypeId =
						(SELECT BETF.Id from BusinessEntityType BETF WHERE BETF.AssetTagKey= 'endCustomer')) AND AU.CreatedByBusinessEntityId = (Select AUF.BusinessEntityId From AppUser Where AUF.UserName = p_UserName)
						UNION
					 SELECT AU.Id,
							AU.UserName as Username,
							AU.DisplayName,
							AR.DisplayName AS RoleName,
							AU.ContactNumber,
							AU.ContactName,
							AU.LastLoginOn,
							AU.IsActive,
							AU.AssetVisibility,
							BET.DisplayName as BusinessEntity,
                            BE.DisplayName as BusinessEntityName,
							TR.TotalRows
					 		FROM  CTE_TotalRows TR, AppUser AU
                            INNER JOIN AppRole AR ON AU.AppRoleId = AR.Id
							LEFT OUTER JOIN BusinessEntity BE ON AU.BusinessEntityId = BE.Id
							LEFT OUTER JOIN BusinessEntityType BET ON BE.BusinessEntityTypeId = BET.Id 
							WHERE AU.BusinessEntityId = (SELECT AUFF.BusinessEntityId FROM AUFF.AppUser WHERE AUFF.UserName = p_UserName)) T
							ORDER BY
							CASE WHEN p_SortingCol = 'UserName' AND p_SortType ='ASC' THEN T.UserName END ,
                            CASE WHEN p_SortingCol = 'UserName' AND p_SortType ='DESC' THEN T.UserName END DESC,
                            CASE WHEN p_SortingCol = 'RoleName' AND p_SortType ='ASC' THEN T.RoleName END ,
                            CASE WHEN p_SortingCol = 'RoleName' AND p_SortType ='DESC' THEN T.RoleName END DESC,
                            CASE WHEN p_SortingCol = 'DisplayName' AND p_SortType ='ASC' THEN T.DisplayName END ,
                            CASE WHEN p_SortingCol = 'DisplayName' AND p_SortType ='DESC' THEN T.DisplayName END DESC,    
                            CASE WHEN p_SortingCol = 'BusinessEntity' AND p_SortType ='ASC' THEN T.DisplayName END ,
                            CASE WHEN p_SortingCol = 'BusinessEntity' AND p_SortType ='DESC' THEN T.DisplayName END DESC,
                            CASE WHEN p_SortingCol = 'IsActive' AND p_SortType ='ASC' THEN T.IsActive END ,
                            CASE WHEN p_SortingCol = 'IsActive' AND p_SortType ='DESC' THEN T.IsActive END DESC,
                            CASE WHEN p_SortingCol = 'LastLoginOn' AND p_SortType ='ASC' THEN T.LastLoginOn END ,
                            CASE WHEN p_SortingCol = 'LastLoginOn' AND p_SortType ='DESC' THEN T.LastLoginOn END DESC
						OFFSET (p_PageNumber-1)*@PageSize
                        FETCH NEXT p_PageSize ROWS ONLY;
			END IF;
END;
$$;


ALTER FUNCTION public.usersbyrules(p_username character varying, p_businessentityid uuid, p_sortingcol character varying, p_sorttype character varying, p_pagenumber integer, p_pagesize integer) OWNER TO c550sqladmin;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: app; Type: TABLE; Schema: public; Owner: c550sqladmin
--

CREATE TABLE public.app (
    id integer NOT NULL,
    domain character varying(100) NOT NULL,
    appname character varying(100),
    displayname character varying(100),
    description character varying(100),
    appicon character varying(500),
    customerlogo character varying(500),
    appadminid integer,
    assethierarchytemplate jsonb,
    updatedby integer,
    updatedon timestamp without time zone
);


ALTER TABLE public.app OWNER TO c550sqladmin;

--
-- Name: app_id_seq; Type: SEQUENCE; Schema: public; Owner: c550sqladmin
--

CREATE SEQUENCE public.app_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.app_id_seq OWNER TO c550sqladmin;

--
-- Name: app_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: c550sqladmin
--

ALTER SEQUENCE public.app_id_seq OWNED BY public.app.id;


--
-- Name: approle; Type: TABLE; Schema: public; Owner: c550sqladmin
--

CREATE TABLE public.approle (
    id integer NOT NULL,
    displayname character varying(200),
    claims text,
    features text,
    whomicancreate text,
    whocancreateme text,
    defaultuservisibility smallint,
    linkedbusinessentitytype integer,
    createdby integer,
    createdon timestamp without time zone,
    updatedby integer,
    updatedon timestamp without time zone
);


ALTER TABLE public.approle OWNER TO c550sqladmin;

--
-- Name: approle_id_seq; Type: SEQUENCE; Schema: public; Owner: c550sqladmin
--

CREATE SEQUENCE public.approle_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.approle_id_seq OWNER TO c550sqladmin;

--
-- Name: approle_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: c550sqladmin
--

ALTER SEQUENCE public.approle_id_seq OWNED BY public.approle.id;


--
-- Name: appuser; Type: TABLE; Schema: public; Owner: c550sqladmin
--

CREATE TABLE public.appuser (
    id integer NOT NULL,
    username character varying(100) NOT NULL,
    displayname character varying(50),
    approleid integer NOT NULL,
    contactname character varying(100) NOT NULL,
    lastloginon timestamp without time zone,
    assetvisibility jsonb,
    businessentityid uuid,
    createdby integer,
    createdon timestamp without time zone NOT NULL,
    updatedby integer,
    updatedon timestamp without time zone,
    isactive boolean NOT NULL,
    createdbybusinessentityid uuid,
    firstname character varying(50),
    lastname character varying(50)
);


ALTER TABLE public.appuser OWNER TO c550sqladmin;

--
-- Name: appuser_id_seq; Type: SEQUENCE; Schema: public; Owner: c550sqladmin
--

CREATE SEQUENCE public.appuser_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.appuser_id_seq OWNER TO c550sqladmin;

--
-- Name: appuser_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: c550sqladmin
--

ALTER SEQUENCE public.appuser_id_seq OWNED BY public.appuser.id;


--
-- Name: asset; Type: TABLE; Schema: public; Owner: c550sqladmin
--

CREATE TABLE public.asset (
    id character varying(50) NOT NULL,
    displayname character varying(100),
    assettags jsonb,
    assetvisibility jsonb,
    location public.geometry(Point,4326),
    status integer NOT NULL,
    connectivitystatus boolean,
    macid character varying(50),
    serialnumber character varying(50),
    gatewayid character varying(50),
    createdon timestamp without time zone NOT NULL,
    createdby integer,
    updatedon timestamp without time zone,
    updatedby integer
);


ALTER TABLE public.asset OWNER TO c550sqladmin;

--
-- Name: assetdata; Type: TABLE; Schema: public; Owner: c550sqladmin
--

CREATE TABLE public.assetdata (
    id character varying(50) NOT NULL,
    diagnostic jsonb,
    hardwareconfiguration jsonb,
    configuration jsonb,
    licensereportedproperties jsonb
);


ALTER TABLE public.assetdata OWNER TO c550sqladmin;

--
-- Name: assetperipheral; Type: TABLE; Schema: public; Owner: c550sqladmin
--

CREATE TABLE public.assetperipheral (
    id integer NOT NULL,
    assetid character varying(50) NOT NULL,
    name character varying(50) NOT NULL,
    displayname character varying(500),
    type character varying(50),
    protocol character varying(100),
    macid character varying(50),
    productcode character varying(50),
    softwarepackageid integer,
    packageversion character varying(50),
    oemdisplayname character varying(50),
    oemname character varying(50),
    additionalinfo character varying(500),
    installedon timestamp without time zone
);


ALTER TABLE public.assetperipheral OWNER TO c550sqladmin;

--
-- Name: assetperipheral_id_seq; Type: SEQUENCE; Schema: public; Owner: c550sqladmin
--

CREATE SEQUENCE public.assetperipheral_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.assetperipheral_id_seq OWNER TO c550sqladmin;

--
-- Name: assetperipheral_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: c550sqladmin
--

ALTER SEQUENCE public.assetperipheral_id_seq OWNED BY public.assetperipheral.id;


--
-- Name: bulkoperation; Type: TABLE; Schema: public; Owner: c550sqladmin
--

CREATE TABLE public.bulkoperation (
    jobid character varying(100) NOT NULL,
    jobtype character varying(50) NOT NULL,
    payload text NOT NULL,
    targetdevicecount integer NOT NULL,
    scheduledon timestamp without time zone NOT NULL,
    target jsonb NOT NULL,
    processed boolean,
    createdby integer,
    createdon timestamp without time zone,
    status character varying(10)
);


ALTER TABLE public.bulkoperation OWNER TO c550sqladmin;

--
-- Name: bulkoperationbatch; Type: TABLE; Schema: public; Owner: c550sqladmin
--

CREATE TABLE public.bulkoperationbatch (
    jobid character varying(100) NOT NULL,
    iothubjobid character varying(100) NOT NULL,
    payload text NOT NULL,
    processed boolean,
    scheduledon timestamp without time zone NOT NULL
);


ALTER TABLE public.bulkoperationbatch OWNER TO c550sqladmin;

--
-- Name: businessentity; Type: TABLE; Schema: public; Owner: c550sqladmin
--

CREATE TABLE public.businessentity (
    id uuid NOT NULL,
    displayname character varying(50),
    businessentitytypeid integer NOT NULL,
    contactname character varying(100) NOT NULL,
    address jsonb,
    createdby integer,
    createdon timestamp without time zone,
    updatedby integer,
    updatedon timestamp without time zone,
    isactive boolean NOT NULL,
    contactnumber bytea,
    contactemail bytea,
    paymentgatewaycustomerid character varying,
    trialsubscriptionused boolean
);


ALTER TABLE public.businessentity OWNER TO c550sqladmin;

--
-- Name: businessentitytype; Type: TABLE; Schema: public; Owner: c550sqladmin
--

CREATE TABLE public.businessentitytype (
    id integer NOT NULL,
    displayname character varying(50),
    assettagkey character varying(50) NOT NULL,
    category character varying(50),
    type character varying(50)
);


ALTER TABLE public.businessentitytype OWNER TO c550sqladmin;

--
-- Name: configurationdata; Type: TABLE; Schema: public; Owner: c550sqladmin
--

CREATE TABLE public.configurationdata (
    id integer NOT NULL,
    keyname character varying(50) NOT NULL,
    data jsonb NOT NULL
);


ALTER TABLE public.configurationdata OWNER TO c550sqladmin;

--
-- Name: configurationdata_id_seq; Type: SEQUENCE; Schema: public; Owner: c550sqladmin
--

CREATE SEQUENCE public.configurationdata_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.configurationdata_id_seq OWNER TO c550sqladmin;

--
-- Name: configurationdata_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: c550sqladmin
--

ALTER SEQUENCE public.configurationdata_id_seq OWNED BY public.configurationdata.id;


--
-- Name: devicejobs; Type: TABLE; Schema: public; Owner: c550sqladmin
--

CREATE TABLE public.devicejobs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    assetid character varying(50) NOT NULL,
    scheduledon timestamp without time zone NOT NULL,
    processed boolean DEFAULT false,
    payload jsonb NOT NULL
);


ALTER TABLE public.devicejobs OWNER TO c550sqladmin;

--
-- Name: endcustomer; Type: TABLE; Schema: public; Owner: c550sqladmin
--

CREATE TABLE public.endcustomer (
    id integer NOT NULL,
    businessentityid uuid NOT NULL,
    createdby integer,
    createdon timestamp without time zone,
    updatedby integer,
    updatedon timestamp without time zone,
    createdbybusinessentityid uuid
);


ALTER TABLE public.endcustomer OWNER TO c550sqladmin;

--
-- Name: endcustomer_id_seq; Type: SEQUENCE; Schema: public; Owner: c550sqladmin
--

CREATE SEQUENCE public.endcustomer_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.endcustomer_id_seq OWNER TO c550sqladmin;

--
-- Name: endcustomer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: c550sqladmin
--

ALTER SEQUENCE public.endcustomer_id_seq OWNED BY public.endcustomer.id;


--
-- Name: eventstatisticsbyasset; Type: TABLE; Schema: public; Owner: c550sqladmin
--

CREATE TABLE public.eventstatisticsbyasset (
    assetid character varying(50),
    criticalcount integer,
    alarmcount integer,
    criticalcountack integer,
    alarmcountack integer,
    siteid integer,
    updatedon timestamp without time zone
);


ALTER TABLE public.eventstatisticsbyasset OWNER TO c550sqladmin;

--
-- Name: eventstatisticsbysite; Type: TABLE; Schema: public; Owner: c550sqladmin
--

CREATE TABLE public.eventstatisticsbysite (
    siteid integer NOT NULL,
    criticalcount integer,
    alarmcount integer,
    criticalcountack integer,
    alarmcountack integer,
    updatedon timestamp without time zone
);


ALTER TABLE public.eventstatisticsbysite OWNER TO c550sqladmin;

--
-- Name: license; Type: TABLE; Schema: public; Owner: c550sqladmin
--

CREATE TABLE public.license (
    id uuid NOT NULL,
    subscriptionid uuid NOT NULL,
    licensekey character varying(30),
    startdate timestamp without time zone NOT NULL,
    enddate timestamp without time zone NOT NULL,
    assetid character varying,
    appliedon timestamp without time zone,
    createdon timestamp without time zone NOT NULL,
    updatedon timestamp without time zone,
    isactive boolean NOT NULL,
    action character varying(10) NOT NULL
);


ALTER TABLE public.license OWNER TO c550sqladmin;

--
-- Name: licensehistory; Type: TABLE; Schema: public; Owner: c550sqladmin
--

CREATE TABLE public.licensehistory (
    id integer NOT NULL,
    licenseid uuid NOT NULL,
    licensekey character varying(30),
    startdate timestamp without time zone NOT NULL,
    enddate timestamp without time zone NOT NULL,
    isactive boolean NOT NULL,
    assetid character varying,
    appliedon timestamp without time zone,
    createdon timestamp without time zone NOT NULL,
    updatedon timestamp without time zone,
    subscriptionid uuid NOT NULL,
    action character varying(10) NOT NULL
);


ALTER TABLE public.licensehistory OWNER TO c550sqladmin;

--
-- Name: licensehistory_id_seq; Type: SEQUENCE; Schema: public; Owner: c550sqladmin
--

ALTER TABLE public.licensehistory ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.licensehistory_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: prospects; Type: TABLE; Schema: public; Owner: c550sqladmin
--

CREATE TABLE public.prospects (
    id uuid NOT NULL,
    displayname character varying(50) NOT NULL,
    businessentitytypeid integer NOT NULL,
    contactname character varying(100) NOT NULL,
    address jsonb NOT NULL,
    createdon timestamp without time zone NOT NULL,
    updatedon timestamp without time zone,
    contactnumber bytea NOT NULL,
    contactemail bytea NOT NULL,
    isemailverified boolean DEFAULT false NOT NULL,
    emailotp character varying(6) NOT NULL,
    emailotpexpiredon timestamp without time zone NOT NULL,
    paymentgatewaycustomerid character varying(20),
    timestampverificationemail timestamp without time zone,
    userfirstname character varying(100) NOT NULL,
    userlastname character varying(100) NOT NULL,
    usercontact bytea NOT NULL,
    useremail bytea NOT NULL
);


ALTER TABLE public.prospects OWNER TO c550sqladmin;

--
-- Name: site; Type: TABLE; Schema: public; Owner: c550sqladmin
--

CREATE TABLE public.site (
    id integer NOT NULL,
    sitename character varying(100) NOT NULL,
    sitehierarchicaltags jsonb NOT NULL,
    notificationsettings jsonb,
    endcustomerid uuid NOT NULL,
    fieldservicecompanyid uuid NOT NULL,
    createdby integer NOT NULL,
    createdon timestamp without time zone NOT NULL,
    updatedby integer,
    updatedon timestamp without time zone,
    location public.geometry
);


ALTER TABLE public.site OWNER TO c550sqladmin;

--
-- Name: site_id_seq; Type: SEQUENCE; Schema: public; Owner: c550sqladmin
--

CREATE SEQUENCE public.site_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.site_id_seq OWNER TO c550sqladmin;

--
-- Name: site_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: c550sqladmin
--

ALTER SEQUENCE public.site_id_seq OWNED BY public.site.id;


--
-- Name: siteadmin; Type: TABLE; Schema: public; Owner: c550sqladmin
--

CREATE TABLE public.siteadmin (
    siteid integer NOT NULL,
    siteadminid integer NOT NULL,
    createdby integer NOT NULL,
    createdon timestamp without time zone NOT NULL
);


ALTER TABLE public.siteadmin OWNER TO c550sqladmin;

--
-- Name: siteasset; Type: TABLE; Schema: public; Owner: c550sqladmin
--

CREATE TABLE public.siteasset (
    id integer NOT NULL,
    siteid integer NOT NULL,
    assetid character varying(50) NOT NULL,
    createdby integer NOT NULL,
    createdon timestamp without time zone NOT NULL
);


ALTER TABLE public.siteasset OWNER TO c550sqladmin;

--
-- Name: siteasset_id_seq; Type: SEQUENCE; Schema: public; Owner: c550sqladmin
--

CREATE SEQUENCE public.siteasset_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.siteasset_id_seq OWNER TO c550sqladmin;

--
-- Name: siteasset_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: c550sqladmin
--

ALTER SEQUENCE public.siteasset_id_seq OWNED BY public.siteasset.id;


--
-- Name: siteassetuser; Type: TABLE; Schema: public; Owner: c550sqladmin
--

CREATE TABLE public.siteassetuser (
    siteid integer NOT NULL,
    assetid character varying(50) NOT NULL,
    userid integer NOT NULL,
    createdby integer NOT NULL,
    createdon timestamp without time zone NOT NULL
);


ALTER TABLE public.siteassetuser OWNER TO c550sqladmin;

--
-- Name: siteuser; Type: TABLE; Schema: public; Owner: c550sqladmin
--

CREATE TABLE public.siteuser (
    id integer NOT NULL,
    siteid integer NOT NULL,
    userid integer NOT NULL,
    createdby integer NOT NULL,
    createdon timestamp without time zone NOT NULL
);


ALTER TABLE public.siteuser OWNER TO c550sqladmin;

--
-- Name: siteuser_id_seq; Type: SEQUENCE; Schema: public; Owner: c550sqladmin
--

CREATE SEQUENCE public.siteuser_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.siteuser_id_seq OWNER TO c550sqladmin;

--
-- Name: siteuser_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: c550sqladmin
--

ALTER SEQUENCE public.siteuser_id_seq OWNED BY public.siteuser.id;


--
-- Name: softwarepackage; Type: TABLE; Schema: public; Owner: c550sqladmin
--

CREATE TABLE public.softwarepackage (
    id integer NOT NULL,
    displayname character varying(100),
    assetmodelid uuid,
    type integer NOT NULL,
    releasedate timestamp without time zone NOT NULL,
    targetperipheral character varying(50) NOT NULL,
    leastoscompatibleversion character varying(50),
    packagename character varying(500) NOT NULL,
    packageversion character varying(50) NOT NULL,
    checksum text,
    createdby integer NOT NULL,
    createdon timestamp without time zone NOT NULL,
    updatedby integer,
    updatedon timestamp without time zone,
    releasedby integer NOT NULL,
    isactive boolean NOT NULL
);


ALTER TABLE public.softwarepackage OWNER TO c550sqladmin;

--
-- Name: softwarepackage_id_seq; Type: SEQUENCE; Schema: public; Owner: c550sqladmin
--

CREATE SEQUENCE public.softwarepackage_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.softwarepackage_id_seq OWNER TO c550sqladmin;

--
-- Name: softwarepackage_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: c550sqladmin
--

ALTER SEQUENCE public.softwarepackage_id_seq OWNED BY public.softwarepackage.id;


--
-- Name: stripepricing; Type: TABLE; Schema: public; Owner: c550sqladmin
--

CREATE TABLE public.stripepricing (
    id integer NOT NULL,
    tableid character varying NOT NULL,
    trial boolean NOT NULL,
    isdeleted boolean NOT NULL,
    name character varying,
    priority integer
);


ALTER TABLE public.stripepricing OWNER TO c550sqladmin;

--
-- Name: stripepricing_id_seq; Type: SEQUENCE; Schema: public; Owner: c550sqladmin
--

ALTER TABLE public.stripepricing ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.stripepricing_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: subscription; Type: TABLE; Schema: public; Owner: c550sqladmin
--

CREATE TABLE public.subscription (
    id uuid NOT NULL,
    name character varying(50) NOT NULL,
    paymentgatewaysubscriptionid character varying(30) NOT NULL,
    startdate timestamp without time zone NOT NULL,
    enddate timestamp without time zone NOT NULL,
    licensecount integer NOT NULL,
    metadata jsonb,
    createdon timestamp without time zone NOT NULL,
    updatedon timestamp without time zone,
    renewcount integer,
    renewedon timestamp without time zone,
    businessentityid uuid NOT NULL,
    quantity integer DEFAULT 1 NOT NULL,
    paymentgatewaycustomerid character varying(20) NOT NULL,
    shortcode character varying(50) NOT NULL,
    status character varying(20) NOT NULL,
    subscriptioncount integer NOT NULL
);


ALTER TABLE public.subscription OWNER TO c550sqladmin;

--
-- Name: subscriptionhistory; Type: TABLE; Schema: public; Owner: c550sqladmin
--

CREATE TABLE public.subscriptionhistory (
    id integer NOT NULL,
    subscriptionid uuid NOT NULL,
    name character varying(50) NOT NULL,
    paymentgatewaysubscriptionid character varying(30) NOT NULL,
    startdate timestamp without time zone NOT NULL,
    enddate timestamp without time zone NOT NULL,
    licensecount integer NOT NULL,
    metadata jsonb,
    createdon timestamp without time zone NOT NULL,
    updatedon timestamp without time zone,
    renewcount integer,
    renewedon timestamp without time zone,
    status character varying(20) NOT NULL,
    quantity integer DEFAULT 1 NOT NULL,
    paymentgatewaycustomerid character varying(20) NOT NULL,
    subscriptioncount integer NOT NULL,
    shortcode character varying(50) NOT NULL,
    businessentityid uuid NOT NULL
);


ALTER TABLE public.subscriptionhistory OWNER TO c550sqladmin;

--
-- Name: subscriptionhistory_id_seq; Type: SEQUENCE; Schema: public; Owner: c550sqladmin
--

ALTER TABLE public.subscriptionhistory ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.subscriptionhistory_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: user_role_name; Type: TABLE; Schema: public; Owner: c550sqladmin
--

CREATE TABLE public.user_role_name (
    displayname character varying(200)
);


ALTER TABLE public.user_role_name OWNER TO c550sqladmin;

--
-- Name: widget; Type: TABLE; Schema: public; Owner: c550sqladmin
--

CREATE TABLE public.widget (
    id integer NOT NULL,
    displayname character varying(100),
    widgetsize character varying(50) NOT NULL,
    data jsonb,
    charttype character varying(50) NOT NULL,
    colortheme integer NOT NULL,
    peripheral text,
    preference text,
    createdby integer,
    createdon timestamp without time zone NOT NULL,
    updatedby integer,
    updatedon timestamp without time zone,
    widgetcode character varying(51) GENERATED ALWAYS AS (('W'::text || ((id)::character varying)::text)) STORED,
    assetid character varying(50),
    overlaykeys text,
    isforlivedashboard boolean,
    unit character varying(50)
);


ALTER TABLE public.widget OWNER TO c550sqladmin;

--
-- Name: widget_id_seq; Type: SEQUENCE; Schema: public; Owner: c550sqladmin
--

CREATE SEQUENCE public.widget_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.widget_id_seq OWNER TO c550sqladmin;

--
-- Name: widget_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: c550sqladmin
--

ALTER SEQUENCE public.widget_id_seq OWNED BY public.widget.id;


--
-- Name: app id; Type: DEFAULT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.app ALTER COLUMN id SET DEFAULT nextval('public.app_id_seq'::regclass);


--
-- Name: approle id; Type: DEFAULT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.approle ALTER COLUMN id SET DEFAULT nextval('public.approle_id_seq'::regclass);


--
-- Name: appuser id; Type: DEFAULT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.appuser ALTER COLUMN id SET DEFAULT nextval('public.appuser_id_seq'::regclass);


--
-- Name: assetperipheral id; Type: DEFAULT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.assetperipheral ALTER COLUMN id SET DEFAULT nextval('public.assetperipheral_id_seq'::regclass);


--
-- Name: configurationdata id; Type: DEFAULT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.configurationdata ALTER COLUMN id SET DEFAULT nextval('public.configurationdata_id_seq'::regclass);


--
-- Name: endcustomer id; Type: DEFAULT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.endcustomer ALTER COLUMN id SET DEFAULT nextval('public.endcustomer_id_seq'::regclass);


--
-- Name: site id; Type: DEFAULT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.site ALTER COLUMN id SET DEFAULT nextval('public.site_id_seq'::regclass);


--
-- Name: siteasset id; Type: DEFAULT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.siteasset ALTER COLUMN id SET DEFAULT nextval('public.siteasset_id_seq'::regclass);


--
-- Name: siteuser id; Type: DEFAULT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.siteuser ALTER COLUMN id SET DEFAULT nextval('public.siteuser_id_seq'::regclass);


--
-- Name: softwarepackage id; Type: DEFAULT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.softwarepackage ALTER COLUMN id SET DEFAULT nextval('public.softwarepackage_id_seq'::regclass);


--
-- Name: widget id; Type: DEFAULT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.widget ALTER COLUMN id SET DEFAULT nextval('public.widget_id_seq'::regclass);


--
-- Name: licensehistory LicenseHistory_pkey; Type: CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.licensehistory
    ADD CONSTRAINT "LicenseHistory_pkey" PRIMARY KEY (id);


--
-- Name: license License_pkey; Type: CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.license
    ADD CONSTRAINT "License_pkey" PRIMARY KEY (id);


--
-- Name: app app_pkey; Type: CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.app
    ADD CONSTRAINT app_pkey PRIMARY KEY (id);


--
-- Name: approle approle_pkey; Type: CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.approle
    ADD CONSTRAINT approle_pkey PRIMARY KEY (id);


--
-- Name: appuser appuser_pkey; Type: CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.appuser
    ADD CONSTRAINT appuser_pkey PRIMARY KEY (id);


--
-- Name: asset asset_pkey; Type: CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.asset
    ADD CONSTRAINT asset_pkey PRIMARY KEY (id);


--
-- Name: assetdata assetdata_pkey; Type: CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.assetdata
    ADD CONSTRAINT assetdata_pkey PRIMARY KEY (id);


--
-- Name: assetperipheral assetperipheral_pkey; Type: CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.assetperipheral
    ADD CONSTRAINT assetperipheral_pkey PRIMARY KEY (id);


--
-- Name: bulkoperation bulkoperation_pkey; Type: CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.bulkoperation
    ADD CONSTRAINT bulkoperation_pkey PRIMARY KEY (jobid);


--
-- Name: businessentity businessentity_pkey; Type: CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.businessentity
    ADD CONSTRAINT businessentity_pkey PRIMARY KEY (id);


--
-- Name: businessentitytype businessentitytype_pkey; Type: CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.businessentitytype
    ADD CONSTRAINT businessentitytype_pkey PRIMARY KEY (id);


--
-- Name: configurationdata configurationdata_pkey; Type: CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.configurationdata
    ADD CONSTRAINT configurationdata_pkey PRIMARY KEY (id);


--
-- Name: devicejobs devicejobs_pkey; Type: CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.devicejobs
    ADD CONSTRAINT devicejobs_pkey PRIMARY KEY (id);


--
-- Name: endcustomer endcustomer_pkey; Type: CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.endcustomer
    ADD CONSTRAINT endcustomer_pkey PRIMARY KEY (id);


--
-- Name: prospects prospects_pkey; Type: CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.prospects
    ADD CONSTRAINT prospects_pkey PRIMARY KEY (id);


--
-- Name: site site_pkey; Type: CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.site
    ADD CONSTRAINT site_pkey PRIMARY KEY (id);


--
-- Name: siteadmin siteadmin_pkey; Type: CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.siteadmin
    ADD CONSTRAINT siteadmin_pkey PRIMARY KEY (siteid, siteadminid);


--
-- Name: siteasset siteasset_pkey; Type: CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.siteasset
    ADD CONSTRAINT siteasset_pkey PRIMARY KEY (id);


--
-- Name: siteassetuser siteassetuser_pkey; Type: CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.siteassetuser
    ADD CONSTRAINT siteassetuser_pkey PRIMARY KEY (siteid, assetid, userid);


--
-- Name: siteuser siteuser_pkey; Type: CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.siteuser
    ADD CONSTRAINT siteuser_pkey PRIMARY KEY (id);


--
-- Name: softwarepackage softwarepackage_pkey; Type: CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.softwarepackage
    ADD CONSTRAINT softwarepackage_pkey PRIMARY KEY (id);


--
-- Name: stripepricing stripepricing_pkey; Type: CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.stripepricing
    ADD CONSTRAINT stripepricing_pkey PRIMARY KEY (id);


--
-- Name: subscription subscription_pkey; Type: CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.subscription
    ADD CONSTRAINT subscription_pkey PRIMARY KEY (id) INCLUDE (id);


--
-- Name: subscriptionhistory subscriptionhistory_pkey; Type: CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.subscriptionhistory
    ADD CONSTRAINT subscriptionhistory_pkey PRIMARY KEY (id) INCLUDE (id);


--
-- Name: widget widget_pkey; Type: CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.widget
    ADD CONSTRAINT widget_pkey PRIMARY KEY (id);


--
-- Name: fki_FK_License_Subscriptionid; Type: INDEX; Schema: public; Owner: c550sqladmin
--

CREATE INDEX "fki_FK_License_Subscriptionid" ON public.license USING btree (subscriptionid);


--
-- Name: bulkoperation CreatedBy_User_fk; Type: FK CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.bulkoperation
    ADD CONSTRAINT "CreatedBy_User_fk" FOREIGN KEY (createdby) REFERENCES public.appuser(id) NOT VALID;


--
-- Name: license FK_License_Subscriptionid; Type: FK CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.license
    ADD CONSTRAINT "FK_License_Subscriptionid" FOREIGN KEY (subscriptionid) REFERENCES public.subscription(id);


--
-- Name: devicejobs devicejobs_assetid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.devicejobs
    ADD CONSTRAINT devicejobs_assetid_fkey FOREIGN KEY (assetid) REFERENCES public.asset(id);


--
-- Name: app fk_app_appadminid; Type: FK CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.app
    ADD CONSTRAINT fk_app_appadminid FOREIGN KEY (appadminid) REFERENCES public.appuser(id);


--
-- Name: app fk_app_updatedby; Type: FK CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.app
    ADD CONSTRAINT fk_app_updatedby FOREIGN KEY (updatedby) REFERENCES public.appuser(id);


--
-- Name: approle fk_approle_appuser; Type: FK CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.approle
    ADD CONSTRAINT fk_approle_appuser FOREIGN KEY (createdby) REFERENCES public.appuser(id);


--
-- Name: approle fk_approle_appuser1; Type: FK CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.approle
    ADD CONSTRAINT fk_approle_appuser1 FOREIGN KEY (updatedby) REFERENCES public.appuser(id);


--
-- Name: approle fk_approle_businessentitytype; Type: FK CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.approle
    ADD CONSTRAINT fk_approle_businessentitytype FOREIGN KEY (linkedbusinessentitytype) REFERENCES public.businessentitytype(id);


--
-- Name: appuser fk_appuser_approle; Type: FK CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.appuser
    ADD CONSTRAINT fk_appuser_approle FOREIGN KEY (approleid) REFERENCES public.approle(id);


--
-- Name: appuser fk_appuser_businessentity; Type: FK CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.appuser
    ADD CONSTRAINT fk_appuser_businessentity FOREIGN KEY (businessentityid) REFERENCES public.businessentity(id);


--
-- Name: appuser fk_appuser_created; Type: FK CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.appuser
    ADD CONSTRAINT fk_appuser_created FOREIGN KEY (createdby) REFERENCES public.appuser(id);


--
-- Name: appuser fk_appuser_updated; Type: FK CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.appuser
    ADD CONSTRAINT fk_appuser_updated FOREIGN KEY (updatedby) REFERENCES public.appuser(id);


--
-- Name: siteasset fk_assetId; Type: FK CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.siteasset
    ADD CONSTRAINT "fk_assetId" FOREIGN KEY (assetid) REFERENCES public.asset(id) NOT VALID;


--
-- Name: siteassetuser fk_assetId; Type: FK CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.siteassetuser
    ADD CONSTRAINT "fk_assetId" FOREIGN KEY (assetid) REFERENCES public.asset(id) NOT VALID;


--
-- Name: asset fk_asset_createdby; Type: FK CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.asset
    ADD CONSTRAINT fk_asset_createdby FOREIGN KEY (createdby) REFERENCES public.appuser(id);


--
-- Name: asset fk_asset_updatedby; Type: FK CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.asset
    ADD CONSTRAINT fk_asset_updatedby FOREIGN KEY (updatedby) REFERENCES public.appuser(id);


--
-- Name: assetdata fk_assetdata_asset; Type: FK CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.assetdata
    ADD CONSTRAINT fk_assetdata_asset FOREIGN KEY (id) REFERENCES public.asset(id);


--
-- Name: assetperipheral fk_assetperipheral_asset; Type: FK CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.assetperipheral
    ADD CONSTRAINT fk_assetperipheral_asset FOREIGN KEY (assetid) REFERENCES public.asset(id);


--
-- Name: assetperipheral fk_assetperipheral_softwarepackage; Type: FK CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.assetperipheral
    ADD CONSTRAINT fk_assetperipheral_softwarepackage FOREIGN KEY (softwarepackageid) REFERENCES public.softwarepackage(id);


--
-- Name: businessentity fk_businessentity_businessentitytype; Type: FK CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.businessentity
    ADD CONSTRAINT fk_businessentity_businessentitytype FOREIGN KEY (businessentitytypeid) REFERENCES public.businessentitytype(id);


--
-- Name: businessentity fk_businessentity_createdby; Type: FK CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.businessentity
    ADD CONSTRAINT fk_businessentity_createdby FOREIGN KEY (createdby) REFERENCES public.appuser(id);


--
-- Name: businessentity fk_businessentity_updatedby; Type: FK CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.businessentity
    ADD CONSTRAINT fk_businessentity_updatedby FOREIGN KEY (updatedby) REFERENCES public.appuser(id);


--
-- Name: site fk_createdBy; Type: FK CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.site
    ADD CONSTRAINT "fk_createdBy" FOREIGN KEY (createdby) REFERENCES public.appuser(id) NOT VALID;


--
-- Name: siteadmin fk_createdBy; Type: FK CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.siteadmin
    ADD CONSTRAINT "fk_createdBy" FOREIGN KEY (createdby) REFERENCES public.appuser(id) NOT VALID;


--
-- Name: siteassetuser fk_createdBy; Type: FK CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.siteassetuser
    ADD CONSTRAINT "fk_createdBy" FOREIGN KEY (createdby) REFERENCES public.appuser(id) NOT VALID;


--
-- Name: siteuser fk_createdBy; Type: FK CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.siteuser
    ADD CONSTRAINT "fk_createdBy" FOREIGN KEY (createdby) REFERENCES public.appuser(id) NOT VALID;


--
-- Name: site fk_endCustomerId; Type: FK CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.site
    ADD CONSTRAINT "fk_endCustomerId" FOREIGN KEY (endcustomerid) REFERENCES public.businessentity(id) NOT VALID;


--
-- Name: endcustomer fk_endcustomer_businessentity; Type: FK CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.endcustomer
    ADD CONSTRAINT fk_endcustomer_businessentity FOREIGN KEY (businessentityid) REFERENCES public.businessentity(id);


--
-- Name: endcustomer fk_endcustomer_createdby; Type: FK CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.endcustomer
    ADD CONSTRAINT fk_endcustomer_createdby FOREIGN KEY (createdby) REFERENCES public.appuser(id);


--
-- Name: endcustomer fk_endcustomer_createdbybusinessentity; Type: FK CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.endcustomer
    ADD CONSTRAINT fk_endcustomer_createdbybusinessentity FOREIGN KEY (createdbybusinessentityid) REFERENCES public.businessentity(id);


--
-- Name: endcustomer fk_endcustomer_updatedby; Type: FK CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.endcustomer
    ADD CONSTRAINT fk_endcustomer_updatedby FOREIGN KEY (updatedby) REFERENCES public.appuser(id);


--
-- Name: site fk_fieldServiceCompanyId; Type: FK CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.site
    ADD CONSTRAINT "fk_fieldServiceCompanyId" FOREIGN KEY (fieldservicecompanyid) REFERENCES public.businessentity(id) NOT VALID;


--
-- Name: siteadmin fk_siteAdminId; Type: FK CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.siteadmin
    ADD CONSTRAINT "fk_siteAdminId" FOREIGN KEY (siteadminid) REFERENCES public.appuser(id) NOT VALID;


--
-- Name: siteadmin fk_siteId; Type: FK CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.siteadmin
    ADD CONSTRAINT "fk_siteId" FOREIGN KEY (siteid) REFERENCES public.site(id) NOT VALID;


--
-- Name: siteasset fk_siteId; Type: FK CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.siteasset
    ADD CONSTRAINT "fk_siteId" FOREIGN KEY (siteid) REFERENCES public.site(id) NOT VALID;


--
-- Name: siteassetuser fk_siteId; Type: FK CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.siteassetuser
    ADD CONSTRAINT "fk_siteId" FOREIGN KEY (siteid) REFERENCES public.site(id) NOT VALID;


--
-- Name: siteuser fk_siteId; Type: FK CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.siteuser
    ADD CONSTRAINT "fk_siteId" FOREIGN KEY (siteid) REFERENCES public.site(id) NOT VALID;


--
-- Name: softwarepackage fk_softwarepackage_createdby; Type: FK CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.softwarepackage
    ADD CONSTRAINT fk_softwarepackage_createdby FOREIGN KEY (createdby) REFERENCES public.appuser(id);


--
-- Name: softwarepackage fk_softwarepackage_updatedby; Type: FK CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.softwarepackage
    ADD CONSTRAINT fk_softwarepackage_updatedby FOREIGN KEY (updatedby) REFERENCES public.appuser(id);


--
-- Name: siteasset fk_updatedBy; Type: FK CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.siteasset
    ADD CONSTRAINT "fk_updatedBy" FOREIGN KEY (createdby) REFERENCES public.appuser(id) NOT VALID;


--
-- Name: site fk_updatedBy; Type: FK CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.site
    ADD CONSTRAINT "fk_updatedBy" FOREIGN KEY (updatedby) REFERENCES public.appuser(id) NOT VALID;


--
-- Name: siteuser fk_userId; Type: FK CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.siteuser
    ADD CONSTRAINT "fk_userId" FOREIGN KEY (userid) REFERENCES public.appuser(id) NOT VALID;


--
-- Name: widget fk_widget_createdby; Type: FK CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.widget
    ADD CONSTRAINT fk_widget_createdby FOREIGN KEY (createdby) REFERENCES public.appuser(id);


--
-- Name: widget fk_widget_updatedby; Type: FK CONSTRAINT; Schema: public; Owner: c550sqladmin
--

ALTER TABLE ONLY public.widget
    ADD CONSTRAINT fk_widget_updatedby FOREIGN KEY (updatedby) REFERENCES public.appuser(id);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: azure_pg_admin
--

GRANT CREATE ON SCHEMA public TO devc550user;


--
-- Name: SCHEMA cron; Type: ACL; Schema: -; Owner: azuresu
--

GRANT USAGE ON SCHEMA cron TO azure_pg_admin;


--
-- Name: SCHEMA devc550schema; Type: ACL; Schema: -; Owner: c550sqladmin
--

GRANT ALL ON SCHEMA devc550schema TO devc550role;


--
-- Name: FUNCTION alter_job(job_id bigint, schedule text, command text, database text, username text, active boolean); Type: ACL; Schema: cron; Owner: azuresu
--

GRANT ALL ON FUNCTION cron.alter_job(job_id bigint, schedule text, command text, database text, username text, active boolean) TO azure_pg_admin;


--
-- Name: FUNCTION job_cache_invalidate(); Type: ACL; Schema: cron; Owner: azuresu
--

GRANT ALL ON FUNCTION cron.job_cache_invalidate() TO azure_pg_admin;


--
-- Name: FUNCTION schedule(schedule text, command text); Type: ACL; Schema: cron; Owner: azuresu
--

GRANT ALL ON FUNCTION cron.schedule(schedule text, command text) TO azure_pg_admin;


--
-- Name: FUNCTION schedule(job_name text, schedule text, command text); Type: ACL; Schema: cron; Owner: azuresu
--

GRANT ALL ON FUNCTION cron.schedule(job_name text, schedule text, command text) TO azure_pg_admin;


--
-- Name: FUNCTION schedule_in_database(job_name text, schedule text, command text, database text, username text, active boolean); Type: ACL; Schema: cron; Owner: azuresu
--

GRANT ALL ON FUNCTION cron.schedule_in_database(job_name text, schedule text, command text, database text, username text, active boolean) TO azure_pg_admin;


--
-- Name: FUNCTION unschedule(job_id bigint); Type: ACL; Schema: cron; Owner: azuresu
--

GRANT ALL ON FUNCTION cron.unschedule(job_id bigint) TO azure_pg_admin;


--
-- Name: FUNCTION unschedule(job_name name); Type: ACL; Schema: cron; Owner: azuresu
--

GRANT ALL ON FUNCTION cron.unschedule(job_name name) TO azure_pg_admin;


--
-- Name: FUNCTION pg_replication_origin_advance(text, pg_lsn); Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT ALL ON FUNCTION pg_catalog.pg_replication_origin_advance(text, pg_lsn) TO azure_pg_admin;


--
-- Name: FUNCTION pg_replication_origin_create(text); Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT ALL ON FUNCTION pg_catalog.pg_replication_origin_create(text) TO azure_pg_admin;


--
-- Name: FUNCTION pg_replication_origin_drop(text); Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT ALL ON FUNCTION pg_catalog.pg_replication_origin_drop(text) TO azure_pg_admin;


--
-- Name: FUNCTION pg_replication_origin_oid(text); Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT ALL ON FUNCTION pg_catalog.pg_replication_origin_oid(text) TO azure_pg_admin;


--
-- Name: FUNCTION pg_replication_origin_progress(text, boolean); Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT ALL ON FUNCTION pg_catalog.pg_replication_origin_progress(text, boolean) TO azure_pg_admin;


--
-- Name: FUNCTION pg_replication_origin_session_is_setup(); Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT ALL ON FUNCTION pg_catalog.pg_replication_origin_session_is_setup() TO azure_pg_admin;


--
-- Name: FUNCTION pg_replication_origin_session_progress(boolean); Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT ALL ON FUNCTION pg_catalog.pg_replication_origin_session_progress(boolean) TO azure_pg_admin;


--
-- Name: FUNCTION pg_replication_origin_session_reset(); Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT ALL ON FUNCTION pg_catalog.pg_replication_origin_session_reset() TO azure_pg_admin;


--
-- Name: FUNCTION pg_replication_origin_session_setup(text); Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT ALL ON FUNCTION pg_catalog.pg_replication_origin_session_setup(text) TO azure_pg_admin;


--
-- Name: FUNCTION pg_replication_origin_xact_reset(); Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT ALL ON FUNCTION pg_catalog.pg_replication_origin_xact_reset() TO azure_pg_admin;


--
-- Name: FUNCTION pg_replication_origin_xact_setup(pg_lsn, timestamp with time zone); Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT ALL ON FUNCTION pg_catalog.pg_replication_origin_xact_setup(pg_lsn, timestamp with time zone) TO azure_pg_admin;


--
-- Name: FUNCTION pg_show_replication_origin_status(OUT local_id oid, OUT external_id text, OUT remote_lsn pg_lsn, OUT local_lsn pg_lsn); Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT ALL ON FUNCTION pg_catalog.pg_show_replication_origin_status(OUT local_id oid, OUT external_id text, OUT remote_lsn pg_lsn, OUT local_lsn pg_lsn) TO azure_pg_admin;


--
-- Name: FUNCTION pg_stat_reset(); Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT ALL ON FUNCTION pg_catalog.pg_stat_reset() TO azure_pg_admin;


--
-- Name: FUNCTION pg_stat_reset_shared(text); Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT ALL ON FUNCTION pg_catalog.pg_stat_reset_shared(text) TO azure_pg_admin;


--
-- Name: FUNCTION pg_stat_reset_single_function_counters(oid); Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT ALL ON FUNCTION pg_catalog.pg_stat_reset_single_function_counters(oid) TO azure_pg_admin;


--
-- Name: FUNCTION pg_stat_reset_single_table_counters(oid); Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT ALL ON FUNCTION pg_catalog.pg_stat_reset_single_table_counters(oid) TO azure_pg_admin;


--
-- Name: FUNCTION armor(bytea); Type: ACL; Schema: public; Owner: azuresu
--

GRANT ALL ON FUNCTION public.armor(bytea) TO azure_pg_admin;


--
-- Name: FUNCTION armor(bytea, text[], text[]); Type: ACL; Schema: public; Owner: azuresu
--

GRANT ALL ON FUNCTION public.armor(bytea, text[], text[]) TO azure_pg_admin;


--
-- Name: FUNCTION crypt(text, text); Type: ACL; Schema: public; Owner: azuresu
--

GRANT ALL ON FUNCTION public.crypt(text, text) TO azure_pg_admin;


--
-- Name: FUNCTION dearmor(text); Type: ACL; Schema: public; Owner: azuresu
--

GRANT ALL ON FUNCTION public.dearmor(text) TO azure_pg_admin;


--
-- Name: FUNCTION decrypt(bytea, bytea, text); Type: ACL; Schema: public; Owner: azuresu
--

GRANT ALL ON FUNCTION public.decrypt(bytea, bytea, text) TO azure_pg_admin;


--
-- Name: FUNCTION decrypt_iv(bytea, bytea, bytea, text); Type: ACL; Schema: public; Owner: azuresu
--

GRANT ALL ON FUNCTION public.decrypt_iv(bytea, bytea, bytea, text) TO azure_pg_admin;


--
-- Name: FUNCTION digest(bytea, text); Type: ACL; Schema: public; Owner: azuresu
--

GRANT ALL ON FUNCTION public.digest(bytea, text) TO azure_pg_admin;


--
-- Name: FUNCTION digest(text, text); Type: ACL; Schema: public; Owner: azuresu
--

GRANT ALL ON FUNCTION public.digest(text, text) TO azure_pg_admin;


--
-- Name: FUNCTION encrypt(bytea, bytea, text); Type: ACL; Schema: public; Owner: azuresu
--

GRANT ALL ON FUNCTION public.encrypt(bytea, bytea, text) TO azure_pg_admin;


--
-- Name: FUNCTION encrypt_iv(bytea, bytea, bytea, text); Type: ACL; Schema: public; Owner: azuresu
--

GRANT ALL ON FUNCTION public.encrypt_iv(bytea, bytea, bytea, text) TO azure_pg_admin;


--
-- Name: FUNCTION gen_random_bytes(integer); Type: ACL; Schema: public; Owner: azuresu
--

GRANT ALL ON FUNCTION public.gen_random_bytes(integer) TO azure_pg_admin;


--
-- Name: FUNCTION gen_random_uuid(); Type: ACL; Schema: public; Owner: azuresu
--

GRANT ALL ON FUNCTION public.gen_random_uuid() TO azure_pg_admin;


--
-- Name: FUNCTION gen_salt(text); Type: ACL; Schema: public; Owner: azuresu
--

GRANT ALL ON FUNCTION public.gen_salt(text) TO azure_pg_admin;


--
-- Name: FUNCTION gen_salt(text, integer); Type: ACL; Schema: public; Owner: azuresu
--

GRANT ALL ON FUNCTION public.gen_salt(text, integer) TO azure_pg_admin;


--
-- Name: FUNCTION hmac(bytea, bytea, text); Type: ACL; Schema: public; Owner: azuresu
--

GRANT ALL ON FUNCTION public.hmac(bytea, bytea, text) TO azure_pg_admin;


--
-- Name: FUNCTION hmac(text, text, text); Type: ACL; Schema: public; Owner: azuresu
--

GRANT ALL ON FUNCTION public.hmac(text, text, text) TO azure_pg_admin;


--
-- Name: FUNCTION pgp_armor_headers(text, OUT key text, OUT value text); Type: ACL; Schema: public; Owner: azuresu
--

GRANT ALL ON FUNCTION public.pgp_armor_headers(text, OUT key text, OUT value text) TO azure_pg_admin;


--
-- Name: FUNCTION pgp_key_id(bytea); Type: ACL; Schema: public; Owner: azuresu
--

GRANT ALL ON FUNCTION public.pgp_key_id(bytea) TO azure_pg_admin;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea); Type: ACL; Schema: public; Owner: azuresu
--

GRANT ALL ON FUNCTION public.pgp_pub_decrypt(bytea, bytea) TO azure_pg_admin;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea, text); Type: ACL; Schema: public; Owner: azuresu
--

GRANT ALL ON FUNCTION public.pgp_pub_decrypt(bytea, bytea, text) TO azure_pg_admin;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea, text, text); Type: ACL; Schema: public; Owner: azuresu
--

GRANT ALL ON FUNCTION public.pgp_pub_decrypt(bytea, bytea, text, text) TO azure_pg_admin;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea); Type: ACL; Schema: public; Owner: azuresu
--

GRANT ALL ON FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea) TO azure_pg_admin;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text); Type: ACL; Schema: public; Owner: azuresu
--

GRANT ALL ON FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea, text) TO azure_pg_admin;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text, text); Type: ACL; Schema: public; Owner: azuresu
--

GRANT ALL ON FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea, text, text) TO azure_pg_admin;


--
-- Name: FUNCTION pgp_pub_encrypt(text, bytea); Type: ACL; Schema: public; Owner: azuresu
--

GRANT ALL ON FUNCTION public.pgp_pub_encrypt(text, bytea) TO azure_pg_admin;


--
-- Name: FUNCTION pgp_pub_encrypt(text, bytea, text); Type: ACL; Schema: public; Owner: azuresu
--

GRANT ALL ON FUNCTION public.pgp_pub_encrypt(text, bytea, text) TO azure_pg_admin;


--
-- Name: FUNCTION pgp_pub_encrypt_bytea(bytea, bytea); Type: ACL; Schema: public; Owner: azuresu
--

GRANT ALL ON FUNCTION public.pgp_pub_encrypt_bytea(bytea, bytea) TO azure_pg_admin;


--
-- Name: FUNCTION pgp_pub_encrypt_bytea(bytea, bytea, text); Type: ACL; Schema: public; Owner: azuresu
--

GRANT ALL ON FUNCTION public.pgp_pub_encrypt_bytea(bytea, bytea, text) TO azure_pg_admin;


--
-- Name: FUNCTION pgp_sym_decrypt(bytea, text); Type: ACL; Schema: public; Owner: azuresu
--

GRANT ALL ON FUNCTION public.pgp_sym_decrypt(bytea, text) TO azure_pg_admin;


--
-- Name: FUNCTION pgp_sym_decrypt(bytea, text, text); Type: ACL; Schema: public; Owner: azuresu
--

GRANT ALL ON FUNCTION public.pgp_sym_decrypt(bytea, text, text) TO azure_pg_admin;


--
-- Name: FUNCTION pgp_sym_decrypt_bytea(bytea, text); Type: ACL; Schema: public; Owner: azuresu
--

GRANT ALL ON FUNCTION public.pgp_sym_decrypt_bytea(bytea, text) TO azure_pg_admin;


--
-- Name: FUNCTION pgp_sym_decrypt_bytea(bytea, text, text); Type: ACL; Schema: public; Owner: azuresu
--

GRANT ALL ON FUNCTION public.pgp_sym_decrypt_bytea(bytea, text, text) TO azure_pg_admin;


--
-- Name: FUNCTION pgp_sym_encrypt(text, text); Type: ACL; Schema: public; Owner: azuresu
--

GRANT ALL ON FUNCTION public.pgp_sym_encrypt(text, text) TO azure_pg_admin;


--
-- Name: FUNCTION pgp_sym_encrypt(text, text, text); Type: ACL; Schema: public; Owner: azuresu
--

GRANT ALL ON FUNCTION public.pgp_sym_encrypt(text, text, text) TO azure_pg_admin;


--
-- Name: FUNCTION pgp_sym_encrypt_bytea(bytea, text); Type: ACL; Schema: public; Owner: azuresu
--

GRANT ALL ON FUNCTION public.pgp_sym_encrypt_bytea(bytea, text) TO azure_pg_admin;


--
-- Name: FUNCTION pgp_sym_encrypt_bytea(bytea, text, text); Type: ACL; Schema: public; Owner: azuresu
--

GRANT ALL ON FUNCTION public.pgp_sym_encrypt_bytea(bytea, text, text) TO azure_pg_admin;


--
-- Name: COLUMN pg_config.name; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(name) ON TABLE pg_catalog.pg_config TO azure_pg_admin;


--
-- Name: COLUMN pg_config.setting; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(setting) ON TABLE pg_catalog.pg_config TO azure_pg_admin;


--
-- Name: COLUMN pg_hba_file_rules.line_number; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(line_number) ON TABLE pg_catalog.pg_hba_file_rules TO azure_pg_admin;


--
-- Name: COLUMN pg_hba_file_rules.type; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(type) ON TABLE pg_catalog.pg_hba_file_rules TO azure_pg_admin;


--
-- Name: COLUMN pg_hba_file_rules.database; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(database) ON TABLE pg_catalog.pg_hba_file_rules TO azure_pg_admin;


--
-- Name: COLUMN pg_hba_file_rules.user_name; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(user_name) ON TABLE pg_catalog.pg_hba_file_rules TO azure_pg_admin;


--
-- Name: COLUMN pg_hba_file_rules.address; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(address) ON TABLE pg_catalog.pg_hba_file_rules TO azure_pg_admin;


--
-- Name: COLUMN pg_hba_file_rules.netmask; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(netmask) ON TABLE pg_catalog.pg_hba_file_rules TO azure_pg_admin;


--
-- Name: COLUMN pg_hba_file_rules.auth_method; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(auth_method) ON TABLE pg_catalog.pg_hba_file_rules TO azure_pg_admin;


--
-- Name: COLUMN pg_hba_file_rules.options; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(options) ON TABLE pg_catalog.pg_hba_file_rules TO azure_pg_admin;


--
-- Name: COLUMN pg_hba_file_rules.error; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(error) ON TABLE pg_catalog.pg_hba_file_rules TO azure_pg_admin;


--
-- Name: COLUMN pg_replication_origin_status.local_id; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(local_id) ON TABLE pg_catalog.pg_replication_origin_status TO azure_pg_admin;


--
-- Name: COLUMN pg_replication_origin_status.external_id; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(external_id) ON TABLE pg_catalog.pg_replication_origin_status TO azure_pg_admin;


--
-- Name: COLUMN pg_replication_origin_status.remote_lsn; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(remote_lsn) ON TABLE pg_catalog.pg_replication_origin_status TO azure_pg_admin;


--
-- Name: COLUMN pg_replication_origin_status.local_lsn; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(local_lsn) ON TABLE pg_catalog.pg_replication_origin_status TO azure_pg_admin;


--
-- Name: COLUMN pg_shmem_allocations.name; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(name) ON TABLE pg_catalog.pg_shmem_allocations TO azure_pg_admin;


--
-- Name: COLUMN pg_shmem_allocations.off; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(off) ON TABLE pg_catalog.pg_shmem_allocations TO azure_pg_admin;


--
-- Name: COLUMN pg_shmem_allocations.size; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(size) ON TABLE pg_catalog.pg_shmem_allocations TO azure_pg_admin;


--
-- Name: COLUMN pg_shmem_allocations.allocated_size; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(allocated_size) ON TABLE pg_catalog.pg_shmem_allocations TO azure_pg_admin;


--
-- Name: COLUMN pg_statistic.starelid; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(starelid) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- Name: COLUMN pg_statistic.staattnum; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(staattnum) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- Name: COLUMN pg_statistic.stainherit; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stainherit) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- Name: COLUMN pg_statistic.stanullfrac; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stanullfrac) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- Name: COLUMN pg_statistic.stawidth; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stawidth) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- Name: COLUMN pg_statistic.stadistinct; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stadistinct) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- Name: COLUMN pg_statistic.stakind1; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stakind1) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- Name: COLUMN pg_statistic.stakind2; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stakind2) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- Name: COLUMN pg_statistic.stakind3; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stakind3) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- Name: COLUMN pg_statistic.stakind4; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stakind4) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- Name: COLUMN pg_statistic.stakind5; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stakind5) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- Name: COLUMN pg_statistic.staop1; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(staop1) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- Name: COLUMN pg_statistic.staop2; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(staop2) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- Name: COLUMN pg_statistic.staop3; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(staop3) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- Name: COLUMN pg_statistic.staop4; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(staop4) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- Name: COLUMN pg_statistic.staop5; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(staop5) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- Name: COLUMN pg_statistic.stacoll1; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stacoll1) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- Name: COLUMN pg_statistic.stacoll2; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stacoll2) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- Name: COLUMN pg_statistic.stacoll3; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stacoll3) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- Name: COLUMN pg_statistic.stacoll4; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stacoll4) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- Name: COLUMN pg_statistic.stacoll5; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stacoll5) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- Name: COLUMN pg_statistic.stanumbers1; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stanumbers1) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- Name: COLUMN pg_statistic.stanumbers2; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stanumbers2) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- Name: COLUMN pg_statistic.stanumbers3; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stanumbers3) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- Name: COLUMN pg_statistic.stanumbers4; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stanumbers4) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- Name: COLUMN pg_statistic.stanumbers5; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stanumbers5) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- Name: COLUMN pg_statistic.stavalues1; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stavalues1) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- Name: COLUMN pg_statistic.stavalues2; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stavalues2) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- Name: COLUMN pg_statistic.stavalues3; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stavalues3) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- Name: COLUMN pg_statistic.stavalues4; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stavalues4) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- Name: COLUMN pg_statistic.stavalues5; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stavalues5) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- Name: COLUMN pg_subscription.oid; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(oid) ON TABLE pg_catalog.pg_subscription TO azure_pg_admin;


--
-- Name: COLUMN pg_subscription.subdbid; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(subdbid) ON TABLE pg_catalog.pg_subscription TO azure_pg_admin;


--
-- Name: COLUMN pg_subscription.subname; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(subname) ON TABLE pg_catalog.pg_subscription TO azure_pg_admin;


--
-- Name: COLUMN pg_subscription.subowner; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(subowner) ON TABLE pg_catalog.pg_subscription TO azure_pg_admin;


--
-- Name: COLUMN pg_subscription.subenabled; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(subenabled) ON TABLE pg_catalog.pg_subscription TO azure_pg_admin;


--
-- Name: COLUMN pg_subscription.subconninfo; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(subconninfo) ON TABLE pg_catalog.pg_subscription TO azure_pg_admin;


--
-- Name: COLUMN pg_subscription.subslotname; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(subslotname) ON TABLE pg_catalog.pg_subscription TO azure_pg_admin;


--
-- Name: COLUMN pg_subscription.subsynccommit; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(subsynccommit) ON TABLE pg_catalog.pg_subscription TO azure_pg_admin;


--
-- Name: COLUMN pg_subscription.subpublications; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(subpublications) ON TABLE pg_catalog.pg_subscription TO azure_pg_admin;


--
-- Name: TABLE app; Type: ACL; Schema: public; Owner: c550sqladmin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.app TO devc550user;


--
-- Name: SEQUENCE app_id_seq; Type: ACL; Schema: public; Owner: c550sqladmin
--

GRANT SELECT,USAGE ON SEQUENCE public.app_id_seq TO devc550user;


--
-- Name: TABLE approle; Type: ACL; Schema: public; Owner: c550sqladmin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.approle TO devc550user;


--
-- Name: SEQUENCE approle_id_seq; Type: ACL; Schema: public; Owner: c550sqladmin
--

GRANT SELECT,USAGE ON SEQUENCE public.approle_id_seq TO devc550user;


--
-- Name: TABLE appuser; Type: ACL; Schema: public; Owner: c550sqladmin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.appuser TO devc550user;


--
-- Name: SEQUENCE appuser_id_seq; Type: ACL; Schema: public; Owner: c550sqladmin
--

GRANT SELECT,USAGE ON SEQUENCE public.appuser_id_seq TO devc550user;


--
-- Name: TABLE asset; Type: ACL; Schema: public; Owner: c550sqladmin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.asset TO devc550user;


--
-- Name: TABLE assetdata; Type: ACL; Schema: public; Owner: c550sqladmin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.assetdata TO devc550user;


--
-- Name: TABLE assetperipheral; Type: ACL; Schema: public; Owner: c550sqladmin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.assetperipheral TO devc550user;


--
-- Name: SEQUENCE assetperipheral_id_seq; Type: ACL; Schema: public; Owner: c550sqladmin
--

GRANT SELECT,USAGE ON SEQUENCE public.assetperipheral_id_seq TO devc550user;


--
-- Name: TABLE bulkoperation; Type: ACL; Schema: public; Owner: c550sqladmin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.bulkoperation TO devc550user;


--
-- Name: TABLE bulkoperationbatch; Type: ACL; Schema: public; Owner: c550sqladmin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.bulkoperationbatch TO devc550user;


--
-- Name: TABLE businessentity; Type: ACL; Schema: public; Owner: c550sqladmin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.businessentity TO devc550user;


--
-- Name: TABLE businessentitytype; Type: ACL; Schema: public; Owner: c550sqladmin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.businessentitytype TO devc550user;


--
-- Name: TABLE configurationdata; Type: ACL; Schema: public; Owner: c550sqladmin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.configurationdata TO devc550user;


--
-- Name: SEQUENCE configurationdata_id_seq; Type: ACL; Schema: public; Owner: c550sqladmin
--

GRANT SELECT,USAGE ON SEQUENCE public.configurationdata_id_seq TO devc550user;


--
-- Name: TABLE devicejobs; Type: ACL; Schema: public; Owner: c550sqladmin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.devicejobs TO devc550user;


--
-- Name: TABLE endcustomer; Type: ACL; Schema: public; Owner: c550sqladmin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.endcustomer TO devc550user;


--
-- Name: SEQUENCE endcustomer_id_seq; Type: ACL; Schema: public; Owner: c550sqladmin
--

GRANT SELECT,USAGE ON SEQUENCE public.endcustomer_id_seq TO devc550user;


--
-- Name: TABLE eventstatisticsbyasset; Type: ACL; Schema: public; Owner: c550sqladmin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.eventstatisticsbyasset TO devc550user;


--
-- Name: TABLE eventstatisticsbysite; Type: ACL; Schema: public; Owner: c550sqladmin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.eventstatisticsbysite TO devc550user;


--
-- Name: TABLE geography_columns; Type: ACL; Schema: public; Owner: c550sqladmin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.geography_columns TO devc550user;


--
-- Name: TABLE geometry_columns; Type: ACL; Schema: public; Owner: c550sqladmin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.geometry_columns TO devc550user;


--
-- Name: TABLE license; Type: ACL; Schema: public; Owner: c550sqladmin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.license TO devc550user;


--
-- Name: TABLE licensehistory; Type: ACL; Schema: public; Owner: c550sqladmin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.licensehistory TO devc550user;


--
-- Name: SEQUENCE licensehistory_id_seq; Type: ACL; Schema: public; Owner: c550sqladmin
--

GRANT SELECT,USAGE ON SEQUENCE public.licensehistory_id_seq TO devc550user;


--
-- Name: TABLE prospects; Type: ACL; Schema: public; Owner: c550sqladmin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.prospects TO devc550user;


--
-- Name: TABLE site; Type: ACL; Schema: public; Owner: c550sqladmin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.site TO devc550user;


--
-- Name: SEQUENCE site_id_seq; Type: ACL; Schema: public; Owner: c550sqladmin
--

GRANT SELECT,USAGE ON SEQUENCE public.site_id_seq TO devc550user;


--
-- Name: TABLE siteadmin; Type: ACL; Schema: public; Owner: c550sqladmin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.siteadmin TO devc550user;


--
-- Name: TABLE siteasset; Type: ACL; Schema: public; Owner: c550sqladmin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.siteasset TO devc550user;


--
-- Name: SEQUENCE siteasset_id_seq; Type: ACL; Schema: public; Owner: c550sqladmin
--

GRANT SELECT,USAGE ON SEQUENCE public.siteasset_id_seq TO devc550user;


--
-- Name: TABLE siteassetuser; Type: ACL; Schema: public; Owner: c550sqladmin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.siteassetuser TO devc550user;


--
-- Name: TABLE siteuser; Type: ACL; Schema: public; Owner: c550sqladmin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.siteuser TO devc550user;


--
-- Name: SEQUENCE siteuser_id_seq; Type: ACL; Schema: public; Owner: c550sqladmin
--

GRANT SELECT,USAGE ON SEQUENCE public.siteuser_id_seq TO devc550user;


--
-- Name: TABLE softwarepackage; Type: ACL; Schema: public; Owner: c550sqladmin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.softwarepackage TO devc550user;


--
-- Name: SEQUENCE softwarepackage_id_seq; Type: ACL; Schema: public; Owner: c550sqladmin
--

GRANT SELECT,USAGE ON SEQUENCE public.softwarepackage_id_seq TO devc550user;


--
-- Name: TABLE spatial_ref_sys; Type: ACL; Schema: public; Owner: c550sqladmin
--

GRANT ALL ON TABLE public.spatial_ref_sys TO azure_pg_admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.spatial_ref_sys TO devc550user;


--
-- Name: TABLE stripepricing; Type: ACL; Schema: public; Owner: c550sqladmin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.stripepricing TO devc550user;


--
-- Name: SEQUENCE stripepricing_id_seq; Type: ACL; Schema: public; Owner: c550sqladmin
--

GRANT SELECT,USAGE ON SEQUENCE public.stripepricing_id_seq TO devc550user;


--
-- Name: TABLE subscription; Type: ACL; Schema: public; Owner: c550sqladmin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.subscription TO devc550user;


--
-- Name: TABLE subscriptionhistory; Type: ACL; Schema: public; Owner: c550sqladmin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.subscriptionhistory TO devc550user;


--
-- Name: SEQUENCE subscriptionhistory_id_seq; Type: ACL; Schema: public; Owner: c550sqladmin
--

GRANT SELECT,USAGE ON SEQUENCE public.subscriptionhistory_id_seq TO devc550user;


--
-- Name: TABLE user_role_name; Type: ACL; Schema: public; Owner: c550sqladmin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.user_role_name TO devc550user;


--
-- Name: TABLE widget; Type: ACL; Schema: public; Owner: c550sqladmin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.widget TO devc550user;


--
-- Name: SEQUENCE widget_id_seq; Type: ACL; Schema: public; Owner: c550sqladmin
--

GRANT SELECT,USAGE ON SEQUENCE public.widget_id_seq TO devc550user;


--
-- PostgreSQL database dump complete
--

