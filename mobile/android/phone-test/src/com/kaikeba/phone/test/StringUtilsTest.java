package com.kaikeba.phone.test;

import junit.framework.TestCase;


import com.kaikeba.common.util.StringUtils;

public class StringUtilsTest extends TestCase {

	public void testFriendlyTime() {
		String sdate = "xx";
		String ddate = "xx";
		
		assertEquals(ddate, StringUtils.friendly_time(sdate));
		assertTrue(true);
	}

    public void testFail() {
        assertTrue(false);
    }
}
