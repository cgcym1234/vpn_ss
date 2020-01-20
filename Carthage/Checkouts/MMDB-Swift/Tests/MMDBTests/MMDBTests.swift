import XCTest
import MMDB

class MMDBTests: XCTestCase {
    var database: MMDB!
    
    override func setUp() {
        super.setUp()
        database = MMDB(Bundle(for: MMDBTests.self).path(forResource: "GeoLite2-Country", ofType: "mmdb")!)
    }

    func testExample() {
        XCTAssertEqual(database.lookup("202.108.22.220")?.isoCode, "CN")
    }

    func testCloudFlare() {
        let cloudflareDNS = database.lookup("1.1.1.1")
        XCTAssertNotNil(cloudflareDNS)
    }
}
